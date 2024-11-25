
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// define the global constants
constant float PI = 3.1415926535f;
constant float characterMovementDampingFactor = 0.15f;
constant float characterModelScale = 0.01f;

// define the motion controller constants
constant uint motionCount = 1;
constant float motionDurations[motionCount] = {
    1.033333f,
};
constant float motionAttacks[motionCount] = {
    0.4f,
};
constant float motionRelatedMovementSpeed[motionCount] = {
    0.027f,
};

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    float4 data;
    
    // define the map data
    //  - mapData.x = blockCount
    uint4 mapData;
    
    // define the character data
    //  - characterData.x = characterCount
    //  - characterData.y = visibleCharacterCount
    uint4 characterData;
    
    // define the position of the observer
    float4 observerPosition;
    
    // define the grid data
    //  - gridData.x = mapGridCount
    uint4 gridData;
    
    // define the grid dimension data
    //  - gridLengthData.x = gridLengthX
    //  - gridLengthData.y = gridLengthZ
    float4 gridLengthData;
    
    // define the frustrum data
    float4 frustumData[6];
};

// define the character data
struct CharacterData {
    
    // define the integer data of the character
    //  - data.x = gender (0: female, 1: male)
    //  - data.y = age (20 - 40)
    //  - data.z = color
    uint4 data;
    
    // define the states of the character
    //  - states.x = goal
    //      - 0 = wandering on the street
    //      - 1 = sleeping (determined by energy)
    //  - states.y = goal planner
    //      - 0 = planning
    //      - 1 = achieving
    //      - 2 = completing
    //      - 3 = terminating
    //      - 4 = terminated
    uint4 states;
    
    // define the stats of the character
    //  - stats[0] = energy (restored by sleeping)
    //  - stats[1] = energy restoration
    //  - stats[2] = energy consumption
    float stats[12];
    
    // define the unique addresses of the character
    //  - addresses[0] = the bed in the apartment
    int4 addresses[4];
    
    // define the navigation data of the character
    //  - navigation.x = the ultimate destination map node index
    //  - navigation.y = the desired map node type
    //  - navigation.z = the temporary destination map node index
    //  - navigation.w = the previous map node index
    int4 navigation;
    
    // define the position of the character
    float4 position;
    
    // define the destination of the character
    float4 destination;
    
    // define the movement data of the character
    //   - movement.x = current speed
    //   - movement.y = target speed
    //   - movement.z = current rotation
    //   - movement.w = target rotation
    float4 movement;
    
    // define the motion controllers
    float4x2 motionControllers[50];
};

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = gender
    //  - data.z = color
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

// define the map node data
struct MapNodeData {
    
    // define the general map node data
    //  - data.x = type
    //  - data.w = connection count
    int4 data;
    
    // define the position of the map node
    float4 position;
    
    // define the dimension of the map node
    float4 dimension;
    
    // define the connections of the map node
    int connections[16];
};

// define the building data
struct BuildingData {
    
    // define the general building data
    //  - data.x = type
    //  - data.w = entrance count
    int4 data;
    
    // define the position of the building
    float4 position;
    
    // define the external entrances of the building
    int externalEntrances[4];
    
    // define the internal entrances of the building
    int internalEntrances[4];
};

// define the grid data
struct GridData {
    
    // define the index of start and end character index
    //  - data.x = start index
    //  - data.y = end index
    uint4 data;
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

// define the function that updates a motion of a character
void updateMotion(thread CharacterData& character, const int motionIndex,
                  const float targetSpeed, const float targetBlendWeight,
                  const float currentTime) {
    float4x2 controller = character.motionControllers[motionIndex];
    const float offset = targetSpeed * (currentTime - controller[3][1]);
    if (offset < motionAttacks[motionIndex]) {
        const float factor = 0.5f - cos(offset / motionAttacks[motionIndex] * PI) * 0.5f;
        controller[1][0] = controller[1][0] * (1.0 - factor) + controller[1][1] * factor;
    } else {
        controller[1][0] = controller[1][1];
    }
    const float progress = fmod(targetSpeed * (currentTime - controller[3][0]),
                                motionDurations[motionIndex]);
    controller[0][0] = motionDurations[motionIndex];
    controller[0][1] = targetSpeed;
    controller[1][1] = clamp(targetBlendWeight, 0.0001f, 1.0f);
    controller[2][0] = motionAttacks[motionIndex];
    controller[2][1] = motionAttacks[motionIndex];
    controller[3][0] = currentTime - (controller[1][0] <= 0.0001f ? 0.0f : progress) / targetSpeed;
    controller[3][1] = currentTime;
    character.motionControllers[motionIndex] = controller;
}

// define the function that updates the navigation data of a character
bool updateNavigation(thread CharacterData& character,
                      const device MapNodeData* mapNodes,
                      const float randomNumber) {
    if (length(character.destination - character.position) > 0.25f) {
        return false;
    }
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    int connections[16];
    int connectionCount = 0;
    int desiredMapNodeIndex = -1;
    for (int index = 0; index < mapNode.data.w; index += 1) {
        const int connection = mapNode.connections[index];
        if (connection == character.navigation.x) {
            character.navigation.w = character.navigation.z;
            character.navigation.z = connection;
            return true;
        }
        if (connection != character.navigation.w) {
            connections[connectionCount] = connection;
            connectionCount += 1;
            if (mapNodes[connection].data.x == character.navigation.y) {
                desiredMapNodeIndex = connection;
            }
        }
    }
    if (connectionCount == 0) {
        character.navigation.w = character.navigation.z;
        character.navigation.z = character.navigation.w;
        return true;
    }
    if (desiredMapNodeIndex >= 0) {
        character.navigation.w = character.navigation.z;
        character.navigation.z = desiredMapNodeIndex;
        return true;
    }
    character.navigation.w = character.navigation.z;
    character.navigation.z = connections[
        int(float(connectionCount) * fract(randomNumber))
    ];
    return true;
}

// define the function that updates the character movement
void updateMovement(thread CharacterData& character, constant FrameData& frame) {
    const float speedOffset = character.movement.y - character.movement.x;
    character.movement.x += speedOffset * frame.data.y * characterMovementDampingFactor;
    while (character.movement.w - character.movement.z > PI) {
        character.movement.w -= PI * 2.0f;
    }
    while (character.movement.z - character.movement.w > PI) {
        character.movement.w += PI * 2.0f;
    }
    const float rotationOffset = character.movement.w - character.movement.z;
    character.movement.z += rotationOffset * frame.data.y * characterMovementDampingFactor;
    const float directionX = cos(character.movement.z);
    const float directionZ = sin(character.movement.z);
    const float3 direction = normalize(float3(directionX, 0.0f, directionZ));
    character.position.xyz += direction * character.movement.x * frame.data.y;
}

// define the simulation function
kernel void SimulationFunction(constant FrameData& frame [[buffer(0)]],
                               device CharacterData* characters [[buffer(1)]],
                               const device MapNodeData* mapNodes [[buffer(2)]],
                               const device BuildingData* buildings [[buffer(3)]],
                               const device GridData* gridData [[buffer(4)]],
                               const device uint* characterIndexBuffer [[buffer(5)]],
                               const device uint* characterCountPerGrid [[buffer(6)]],
                               const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // acquire the current time
    const float currentTime = frame.data.x;
    
    // acquire the current character
    CharacterData character = characters[index];
    
    // perform destination update
    const float3 random = hash3D(fract(character.position.xyz) + float3(currentTime));
    if (updateNavigation(character, mapNodes, random.y)) {
        
        // update the destination
        const MapNodeData mapNode = mapNodes[character.navigation.z];
        character.destination.xyz = mapNode.position.xyz;
        character.destination.x += (2.0f * random.x - 1.0f) * mapNode.dimension.x * 0.3f;
        character.destination.z += (2.0f * random.z - 1.0f) * mapNode.dimension.z * 0.3f;
        
        // update the walk motion controller with the new parameters
        const float animationSpeed = (1.0f - pow(float(character.data.y) - 30.0f, 2.0f) * 0.01f) * 0.4f + 0.8f;
        updateMotion(character, 0, animationSpeed, 1.0f, currentTime);
        
        // update the target speed
        const float scale = 0.6f + float(character.data.y) * 0.01f;
        character.movement.y = animationSpeed * scale * motionRelatedMovementSpeed[0];
    }
    
    // update the target angle
    const float4 direction = normalize(character.destination - character.position);
    character.movement.w = atan2(direction.z, direction.x);
    
    // update the character movement
    updateMovement(character, frame);
    
    // store the new character data
    characters[index] = character;
}

// define the compute grid function
kernel void ComputeGridFunction(constant FrameData& frame [[buffer(0)]],
                                const device CharacterData* characters [[buffer(1)]],
                                device atomic_uint* characterCountPerGrid [[buffer(2)]],
                                const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const float gridLengthX = frame.gridLengthData.x;
    const float gridLengthZ = frame.gridLengthData.y;
    
    const uint gridDim = uint(sqrt(float(frame.gridData.x)));
    const float width = gridLengthX * gridDim;
    const float height = gridLengthZ * gridDim;
    
    const float3 gridCenter = float3(width / 2.0f, 0.0f, height / 2.0f);
    const float3 characterPosition = clamp(characters[index].position.xyz + gridCenter,
                                           float3(0.0f, 0.0f, 0.0f),
                                           float3(width, 0.0f, height));
    
    const uint gridIndexX = uint(characterPosition.x / gridLengthX);
    const uint gridIndexZ = uint(characterPosition.z / gridLengthZ);
    const uint gridIndex = gridIndexX + gridIndexZ * gridDim;
    
    atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
}

// define the assign linked grid function
kernel void AssignLinkedGridFunction(constant FrameData& frame [[buffer(0)]],
                                     const device uint* characterCountPerGrid [[buffer(1)]],
                                     device GridData* gridData [[buffer(2)]],
                                     device atomic_uint* nextAvailableGridIndex [[buffer(3)]],
                                     const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of map grids
    if (index >= frame.gridData.x) {
        return;
    }
    
    const uint charactersInGrid = characterCountPerGrid[index];
    const uint startIndex = atomic_fetch_add_explicit(&nextAvailableGridIndex[0], charactersInGrid, memory_order_relaxed);
    gridData[index].data.x = startIndex;
    gridData[index].data.y = startIndex + charactersInGrid - 1;
}

// define the set character index per grid
kernel void SetCharacterIndexPerGridFunction(constant FrameData& frame [[buffer(0)]],
                                             const device CharacterData* characters [[buffer(1)]],
                                             device atomic_uint* characterCountPerGrid [[buffer(2)]],
                                             device uint* characterIndexBuffer [[buffer(3)]],
                                             const device GridData* gridData [[buffer(4)]],
                                             const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    const float gridLengthX = frame.gridLengthData.x;
    const float gridLengthZ = frame.gridLengthData.y;
    
    const uint gridDim = uint(sqrt(float(frame.gridData.x)));
    const float width = gridLengthX * gridDim;
    const float height = gridLengthZ * gridDim;
    
    const float3 gridCenter = float3(width / 2.0f, 0.0f, height / 2.0f);
    const float3 characterPosition = clamp(characters[index].position.xyz + gridCenter,
                                           float3(0.0f, 0.0f, 0.0f),
                                           float3(width, 0.0f, height));
    
    const uint gridIndexX = uint(characterPosition.x / gridLengthX);
    const uint gridIndexZ = uint(characterPosition.z / gridLengthZ);
    const uint gridIndex = gridIndexX + gridIndexZ * gridDim;
    
    const uint prevCount = atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
    const uint startIndex = gridData[gridIndex].data.x;
    characterIndexBuffer[startIndex + prevCount] = index;
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
    if (dot(frame.frustumData[0], center) < radius) {
        return;
    }
    if (dot(frame.frustumData[1], center) < radius) {
        return;
    }
    if (dot(frame.frustumData[2], center) < radius) {
        return;
    }
    if (dot(frame.frustumData[3], center) < radius) {
        return;
    }
    if (dot(frame.frustumData[4], center) < radius) {
        return;
    }
    if (dot(frame.frustumData[5], center) < radius) {
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
    
    visibleCharacters[index].data.x = characters[visibleCharacterIndex].data.x;
    visibleCharacters[index].data.z = characters[visibleCharacterIndex].data.z;
    
    const float matrixAngle = PI * 0.5f - characters[visibleCharacterIndex].movement.z;
    const float scale = 0.6f + float(characters[visibleCharacterIndex].data.y) * 0.01f;
    const float3x3 rotationMatrixY = scale * characterModelScale * float3x3(
        cos(matrixAngle), 0.0f, -sin(matrixAngle),
        0.0f, 1.0f, 0.0f,
        sin(matrixAngle), 0.0f, cos(matrixAngle)
    );
    
    visibleCharacters[index].transform[0] = float4(rotationMatrixY[0], 0.0f);
    visibleCharacters[index].transform[1] = float4(rotationMatrixY[1], 0.0f);
    visibleCharacters[index].transform[2] = float4(rotationMatrixY[2], 0.0f);
    visibleCharacters[index].transform[3].xyz = characters[visibleCharacterIndex].position.xyz;
    
    if (index >= frame.characterData.z) {
        visibleCharacters[index].transform[3].y = -10000.0f;
    }
    
    // synchronize the motion controllers
    for (int motionIndex = 0; motionIndex < 50; motionIndex += 1) {
        const float4x2 controller = characters[visibleCharacterIndex].motionControllers[motionIndex];
        visibleCharacters[index].motionControllers[motionIndex] = controller;
    }
}
