
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// math constants
constant float PI = 3.1415926535f;

// global constants
constant float CHARACTER_SPACING = 3.0f;
constant float CHARACTER_SCALE = 0.01f;

// motion constants
constant float STOP_PROBABILITY = 0.05f;
constant float SPEED_DAMP_FACTOR = 0.1f;
constant float ROTATION_DAMP_FACTOR = 0.05f;

//animation constants
constant float WALK0_DURATION = 1.033333f;
constant float WALK0_ATTACK = 0.4f;
constant float WALK0_SPEED = 0.027f;

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    float4 data;
    
    // define the character data
    //  - characterData.x = characterCount
    //  - characterData.y = visibleCharacterCount
    uint4 characterData;
    
    // define the position of the observer
    float4 observerPosition;
    
    // define the grid data
    //  - gridData.x = gridDimensionX
    //  - gridData.y = gridDimensionZ
    //  - gridData.z = maxNumCharactersPerGrid
    //  - gridData.w = width/height
    float4 gridData;
    
    // define the frustrum data
    float4 frustumData[6];
};

// define the character data
struct CharacterData {
    
    // characterInformation.x is gender
    // characterInformation.z is current time threshold
    // characterInformation.w is the accumulated time threshold
    float4 characterInformation;
    
    // define the position of the character
    float4 position;
    
    // motionInformation.x is the current speed
    // motionInformation.y is the target speed
    // motionInformation.z is the current anticlockwise angle in radians
    // motionInformation.w is the target anticlockwise rotation angle in radians
    float4 motionInformation;
    
    // define the motion controllers
    float4x2 motionControllers[50];
};

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = sex
    //  - data.w = character node index
    uint4 data;
    
    // define the indices of the female mesh nodes
    float4 femaleMeshNodeIndices;
    
    // define the indices of the male mesh nodes
    float4 maleMeshNodeIndices;
    
    // define the transform of the visible character
    float4x4 transform;
    
    // define the motion controller indices
    int motionControllerIndices[50];
    
    // define the motion controllers
    float4x2 motionControllers[50];
};

float hash1D(float n) {
    return fract(sin(n) * 43758.5453123f);
}

float2 hash2D(float2 p) {
    float n = dot(p, float2(12.9898f, 78.233f));
    return float2(fract(sin(n) * 43758.5453123f),
                  fract(cos(n) * 43758.5453123f));
}

float3 hash3D(float3 p) {
    float n = dot(p, float3(12.9898f, 78.233f, 45.164f));
    return float3(fract(sin(n) * 43758.5453123f),
                  fract(cos(n) * 43758.5453123f),
                  fract(sin(n + PI) * 43758.5453123f));
}

// update a looped motion
float4x2 updateLoopedMotion(float4x2 controller, const float duration,
                            const float weight, const float attack, const float time) {
    const float offset = time - controller[3][1];
    if (offset < attack) {
        const float factor = 0.5f - cos(offset / attack * PI) * 0.5f;
        controller[1][0] = controller[1][0] * (1.0 - factor) + controller[1][1] * factor;
    } else {
        controller[1][0] = controller[1][1];
    }
    const float progress = fmod(time - controller[3][0], duration);
    controller[1][1] = clamp(weight, 0.0001f, 1.0f);
    controller[2] = float2(attack);
    controller[3] = float2(time - (controller[1][0] <= 0.0001f ? 0.0f : progress), time);
    return controller;
}

// define the naive simulation function
kernel void NaiveSimulationFunction(constant FrameData& frame [[buffer(0)]],
                                    device CharacterData* characters [[buffer(1)]],
                                    device VisibleCharacterData* visibleCharacters[[buffer(2)]],
                                    const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const float currentTime = frame.data.x;
    // initailise data
    // should be in a different kernel
    if (currentTime == 0.0f) {
        const float3 rand3D = 2.0f * hash3D(index) - 1.0f;
        // So far we assume that the character's position is only on the xz plane
        characters[index].characterInformation.x = uint(rand3D.x + 1.0f);
        characters[index].motionInformation.y = WALK0_SPEED;
        characters[index].motionInformation.w = rand3D.z * PI;
        
        const int characterCount = int(sqrt(float(frame.characterData.x)));
        const int halfCharacterCount = characterCount / 2;
        characters[index].position.x = float(int(index) % characterCount - halfCharacterCount) * CHARACTER_SPACING;
        characters[index].position.z = float(int(index) / characterCount - halfCharacterCount) * CHARACTER_SPACING;
    }

    if (currentTime > characters[index].characterInformation.w) {
        const float3 rand3D = hash3D(characters[index].position.xyz + float3(currentTime));
        const float minTime = 2.0f;
        const float maxTime = 4.0f;
        const float updatedAngle = (2.0f * rand3D.y - 1.0f) * PI;
        const bool shouldStop = rand3D.x < STOP_PROBABILITY;
        const float blendWeight = shouldStop ? 0.0f : 1.0f;
        
        characters[index].motionInformation.y = shouldStop ? 0.0f : WALK0_SPEED;
        characters[index].motionInformation.w = shouldStop ? characters[index].motionInformation.w : updatedAngle;
        characters[index].characterInformation.z = minTime + rand3D.z * maxTime;
        characters[index].characterInformation.w += characters[index].characterInformation.z;
        
        // acquire the walk motion controller
        float4x2 motionController = characters[index].motionControllers[0];
        
        // update the walk motion controller with the new parameters
        motionController = updateLoopedMotion(motionController, WALK0_DURATION, blendWeight, WALK0_ATTACK, currentTime);
        
        // store the new walk motion controller
        characters[index].motionControllers[0] = motionController;
    }
    
    const float currentWalkingSpeed = characters[index].motionInformation.x;
    const float targetWalkingSpeed = characters[index].motionInformation.y;
    const float currentAngle = characters[index].motionInformation.z;
    float targetAngle = characters[index].motionInformation.w;
    const float3 walkingDirection = normalize(float3(cos(currentAngle), 0.0f, sin(currentAngle)));
    
    // gradual speeding
    characters[index].motionInformation.x += (targetWalkingSpeed - currentWalkingSpeed) * SPEED_DAMP_FACTOR;
    characters[index].position.xyz += walkingDirection * characters[index].motionInformation.x * frame.data.y;
    
    // gradual rotation
    while (targetAngle - currentAngle > PI) {
        targetAngle -= PI * 2.0f;
    }
    while (currentAngle - targetAngle > PI) {
        targetAngle += PI * 2.0f;
    }
    characters[index].motionInformation.w = targetAngle;

    characters[index].motionInformation.z += (characters[index].motionInformation.w - currentAngle) * ROTATION_DAMP_FACTOR;
}

// define the compute grid function
kernel void ComputeGridFunction(constant FrameData& frame [[buffer(0)]],
                                const device CharacterData* characters [[buffer(1)]],
                                device atomic_uint* characterCountPerGrid [[buffer(2)]],
                                device uint* characterIndexBuffer [[buffer(3)]],
                                const uint index [[thread_position_in_grid]]) {
    
    const uint gridDimX = uint(frame.gridData.x);
    const uint gridDimZ = uint(frame.gridData.y);
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const uint width = uint(frame.gridData.w);
    
    const float3 gridCenter = float3(width / 2.0f, 0.0f, width / 2.0f);
    const float3 characterPosition = clamp(characters[index].position.xyz + gridCenter,
                                           float3(0.0f, 0.0f, 0.0f),
                                           float3(width, 0.0f, width));
    const uint maxNumCharactersPerGrid = uint(frame.gridData.z);
    
    const uint2 gridOffset = uint2(width) / uint2(gridDimX, gridDimZ);
    const uint gridIndexX = uint(characterPosition.x) / gridOffset.x;
    const uint gridIndexZ = uint(characterPosition.z) / gridOffset.y;
    
    const uint gridIndex = gridIndexX + gridIndexZ * gridDimX;
    const uint prevIndex = atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
    if (prevIndex < maxNumCharactersPerGrid) {
        characterIndexBuffer[gridIndex * maxNumCharactersPerGrid + prevIndex] = index;
    }
}

// define the find visible characters function
kernel void FindVisibleCharactersFunction(constant FrameData& frame [[buffer(0)]],
                                          const device CharacterData* characters [[buffer(1)]],
                                          device atomic_uint* visibleCharacterCount [[buffer(2)]],
                                          device uint* potentiallyVisibleCharacterIndexBuffer [[buffer(3)]],
                                          device float* visibleCharacterDistanceToObserverBuffer [[buffer(4)]],
                                          const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const float3 characterPosition = characters[index].position.xyz;
    const float4 center = float4(characterPosition.x, characterPosition.y + 1.0f, characterPosition.z, 1.0f);
    const float radius = -2.0f;
    if (dot(frame.frustumData[0], center) < radius){
        return;
    }
    if (dot(frame.frustumData[1], center) < radius){
        return;
    }
    if (dot(frame.frustumData[2], center) < radius){
        return;
    }
    if (dot(frame.frustumData[3], center) < radius){
        return;
    }
    if (dot(frame.frustumData[4], center) < radius){
        return;
    }
    if (dot(frame.frustumData[5], center) < radius){
        return;
    }
    
    const float distance = length(frame.observerPosition.xyz - characters[index].position.xyz);
    const uint prevIndex = atomic_fetch_add_explicit(&visibleCharacterCount[0], 1, memory_order_relaxed);
    potentiallyVisibleCharacterIndexBuffer[prevIndex] = index;
    visibleCharacterDistanceToObserverBuffer[prevIndex] = distance;
}

// define the simulate visible character function
kernel void SimulateVisibleCharacterFunction(constant FrameData& frame [[buffer(0)]],
                                             const device CharacterData* characters [[buffer(1)]],
                                             device VisibleCharacterData* visibleCharacters[[buffer(2)]],
                                             const device uint* visibleCharacterIndexBuffer [[buffer(3)]],
                                             const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of visible characters
    if (index >= frame.characterData.y) {
        return;
    }
    
    uint visibleCharacterIndex = visibleCharacterIndexBuffer[index];
    
    visibleCharacters[index].data.x = characters[visibleCharacterIndex].characterInformation.x;
    
    const float matrixAngle = PI * 0.5f - characters[visibleCharacterIndex].motionInformation.z;
    const float3x3 rotationMatrixY = CHARACTER_SCALE * float3x3(
      cos(matrixAngle), 0.0f, -sin(matrixAngle),
      0.0f, 1.0f, 0.0f,
      sin(matrixAngle), 0.0f, cos(matrixAngle)
    );
    
    visibleCharacters[index].transform[0] = float4(rotationMatrixY[0], 0.0f);
    visibleCharacters[index].transform[1] = float4(rotationMatrixY[1], 0.0f);
    visibleCharacters[index].transform[2] = float4(rotationMatrixY[2], 0.0f);
    visibleCharacters[index].transform[3].xyz = characters[visibleCharacterIndex].position.xyz;
    
    if (index >= frame.characterData.z){
        visibleCharacters[index].transform[3].y = -10000.0f;
    }
    
    // synchronize the motion controllers
    for (int motionIndex = 0; motionIndex < 50; motionIndex += 1) {
        const float4x2 controller = characters[visibleCharacterIndex].motionControllers[motionIndex];
        visibleCharacters[index].motionControllers[motionIndex] = controller;
    }
}
