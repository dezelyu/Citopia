
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

constant float PI = 3.1415926535f;
constant float EPSILON = 0.01f;
constant float3 MAP_DIMENSIONS = float3(30.0f);

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
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
};

// define the character data
struct CharacterData {
    
    // define the position of the character
    float4 position;
    
    // .x is the current anticlockwise angle in radians
    // .y is the target anticlockwise rotation angle in radians
    float4 rotation;
    
    // .x is gender
    // .y is speed
    // .z is current time threshold
    // .w is the accumulated time threshold
    float4 information;
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

// define the naive simulation function
kernel void NaiveSimulationFunction(constant FrameData& frame [[buffer(0)]],
                                    device CharacterData* characters [[buffer(1)]],
                                    device VisibleCharacterData* visibleCharacters[[buffer(2)]],
                                    const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const float curTime = frame.data.x;
    // initailise data
    // should be in a different kernel
    if (curTime == 0.0f) {
        const float3 rand3D = 2.0f * hash3D(index) - 1.0f;
        // So far we assume that the character's position is only on the xz plane
        characters[index].position.xyz = float3(rand3D.x, EPSILON, rand3D.y) * MAP_DIMENSIONS;
        characters[index].rotation.y = rand3D.z * PI;
        characters[index].information.x = uint(rand3D.x + 1.0f);
        characters[index].information.y = 0.03f;
        
        visibleCharacters[index].data.x = characters[index].information.x;
    }

    const float walkingSpeed = characters[index].information.y;
    
    if (curTime > characters[index].information.w) {
        const float minTime = 2.0f;
        const float maxTime = 4.0f;
        const float2 rand2D = hash2D(index + curTime);
        const float updatedAngle = (2.0f * rand2D.x - 1.0f) * PI;
        
        characters[index].rotation.y = updatedAngle;
        characters[index].information.z = minTime + rand2D.y * maxTime;
        characters[index].information.w += characters[index].information.z;
    }
    
    const float angle = characters[index].rotation.x;
    const float3 walkingDirection = normalize(float3(cos(angle), 0.0f, sin(angle)));
    characters[index].position.xyz += walkingDirection * walkingSpeed;
    
    while (characters[index].rotation.y - characters[index].rotation.x > PI) {
        characters[index].rotation.y -= PI * 2.0f;
    }
    while (characters[index].rotation.x - characters[index].rotation.y > PI) {
        characters[index].rotation.y += PI * 2.0f;
    }
    
    characters[index].rotation.x += min((characters[index].rotation.y - characters[index].rotation.x) * 0.05f, 0.05f);
    
    const float matrixAngle = PI * 0.5f - characters[index].rotation.x;
    const float scale = 0.01f;
    const float3x3 rotationMatrixY = scale * float3x3(
      cos(matrixAngle), 0.0f, -sin(matrixAngle),
      0.0f, 1.0f, 0.0f,
      sin(matrixAngle), 0.0f, cos(matrixAngle)
    );
    
    visibleCharacters[index].transform[0] = float4(rotationMatrixY[0], 0.0f);
    visibleCharacters[index].transform[1] = float4(rotationMatrixY[1], 0.0f);
    visibleCharacters[index].transform[2] = float4(rotationMatrixY[2], 0.0f);
    visibleCharacters[index].transform[3].xyz = characters[index].position.xyz;
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
