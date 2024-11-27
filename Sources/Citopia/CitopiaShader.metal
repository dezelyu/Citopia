
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// define the global constants
constant float PI = 3.1415926535f;
constant float characterMovementDampingFactor = 0.1f;
constant float characterModelScale = 0.01f;

// define the motion controller constants
constant uint motionCount = 5;
constant float motionDurations[motionCount] = {
    1.0f,
    1.0f,
    -2.0f,
    -2.0f,
    0.75f,
};
constant float motionAttacks[motionCount] = {
    0.4f,
    1.0f,
    0.4f,
    0.4f,
    0.4f,
};
constant float motionRelatedMovementSpeed[motionCount] = {
    0.027f,
    0.0f,
    0.0f,
    0.0f,
    0.0f,
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
    //      - 2 = working (determined by gold)
    //  - states.y = goal planner state
    uint4 states;
    
    // define the stats of the character
    //  - stats[0] = energy (restored by sleeping)
    //  - stats[1] = energy restoration
    //  - stats[2] = energy consumption
    //  - stats[3] = total gold
    //  - stats[4] = gold earned in the current cycle
    //  - stats[5] = target gold per cycle
    //  - stats[6] = gold earned per frame
    float stats[12];
    
    // define the unique addresses of the character
    //  - addresses[0] = the current address
    //  - addresses[1] = the bed in the apartment
    //  - addresses[2] = the office in the office building
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
    //  - movement.x = current speed
    //  - movement.y = target speed
    //  - movement.z = current rotation
    //  - movement.w = target rotation
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
    //      - 0 = street
    //      - 1 = external entrance
    //      - 2 = internal entrance
    //      - 3 = building
    //      - 4 = bed
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

// define the function that generates a random number
float3 generateRandomNumber(const float3 input) {
    uint3 vector = uint3(input);
    vector.x += (vector.x << 10u);
    vector.x ^= (vector.x >> 6u);
    vector.x += (vector.x << 3u);
    vector.x ^= (vector.x >> 11u);
    vector.x += (vector.x << 15u);
    vector.y += (vector.y << 10u);
    vector.y ^= (vector.y >> 6u);
    vector.y += (vector.y << 3u);
    vector.y ^= (vector.y >> 11u);
    vector.y += (vector.y << 15u);
    vector.z += (vector.z << 10u);
    vector.z ^= (vector.z >> 6u);
    vector.z += (vector.z << 3u);
    vector.z ^= (vector.z >> 11u);
    vector.z += (vector.z << 15u);
    vector.x = vector.x ^ vector.y ^ vector.z;
    vector.y = vector.y ^ vector.z ^ vector.x;
    vector.z = vector.z ^ vector.x ^ vector.y;
    return float3(vector.x & 0xFFFFFFu, vector.y & 0xFFFFFFu, vector.z & 0xFFFFFFu) / 16777216.0f;
}

// define the function that updates a motion of a character
void updateMotion(thread CharacterData& character, const int motionIndex,
                  const float targetSpeed, const float targetBlendWeight,
                  const float currentTime) {
    float4x2 controller = character.motionControllers[motionIndex];
    if (motionDurations[motionIndex] < 0.0f) {
        controller[1][0] = 0.0f;
        controller[1][1] = 0.0f;
        controller[3][0] = currentTime;
        controller[3][1] = currentTime;
    } else {
        const float offset = targetSpeed * (currentTime - controller[3][1]);
        if (offset < motionAttacks[motionIndex]) {
            const float factor = 0.5f - cos(offset / motionAttacks[motionIndex] * PI) * 0.5f;
            controller[1][0] = controller[1][0] * (1.0 - factor) + controller[1][1] * factor;
        } else {
            controller[1][0] = controller[1][1];
        }
    }
    const float progress = fmod(targetSpeed * (currentTime - controller[3][0]), motionDurations[motionIndex]);
    controller[0][0] = motionDurations[motionIndex];
    controller[0][1] = -targetSpeed;
    controller[1][1] = clamp(targetBlendWeight, 0.0001f, 1.0f);
    controller[2][0] = motionAttacks[motionIndex];
    controller[2][1] = motionAttacks[motionIndex];
    controller[3][0] = currentTime - (controller[1][0] <= 0.0001f ? 0.0f : progress) / targetSpeed;
    controller[3][1] = currentTime;
    character.motionControllers[motionIndex] = controller;
}

// defien the function that gets the duration played for a motion
float motionDurationPlayed(thread CharacterData& character, const int motionIndex, const float currentTime) {
    const float4x2 controller = character.motionControllers[motionIndex];
    return currentTime - controller[3][1];
}

// define the function that finds the nearest external entrance
int findNearestExternalEntrance(thread CharacterData& character,
                                const device MapNodeData* mapNodes,
                                const device BuildingData* buildings,
                                const int buildingIndex) {
    const BuildingData building = buildings[buildingIndex];
    float distance = FLT_MAX;
    int entrance;
    for (int index = 0; index < building.data.w; index += 1) {
        const MapNodeData mapNode = mapNodes[building.externalEntrances[index]];
        const float currentDistance = length(character.position - mapNode.position);
        if (distance > currentDistance) {
            distance = currentDistance;
            entrance = building.externalEntrances[index];
        }
    }
    return entrance;
}

// define the function that finds the nearest internal entrance
int findNearestInternalEntrance(thread CharacterData& character,
                                const device MapNodeData* mapNodes,
                                const device BuildingData* buildings,
                                const int buildingIndex) {
    const BuildingData building = buildings[buildingIndex];
    float distance = FLT_MAX;
    int entrance;
    for (int index = 0; index < building.data.w; index += 1) {
        const MapNodeData mapNode = mapNodes[building.internalEntrances[index]];
        const float currentDistance = length(character.position - mapNode.position);
        if (distance > currentDistance) {
            distance = currentDistance;
            entrance = building.internalEntrances[index];
        }
    }
    return entrance;
}

// define the function that navigates the character to exit the current building
void exitCurrentBuilding(thread CharacterData& character,
                         const device MapNodeData* mapNodes,
                         const device BuildingData* buildings) {
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    if (mapNode.data.x == 1) {
        character.addresses[0] = int4(-1);
        character.navigation.x = -1;
        character.navigation.y = 0;
    } else if (mapNode.data.x == 2) {
        character.navigation.x = findNearestExternalEntrance(character, mapNodes, buildings,
                                                             character.addresses[0].x);
        character.navigation.y = 1;
    } else {
        character.navigation.x = findNearestInternalEntrance(character, mapNodes, buildings,
                                                             character.addresses[0].x);
        character.navigation.y = 3;
    }
}

// implement the function that navigates the character to a building
void moveToBuilding(thread CharacterData& character,
                    const device MapNodeData* mapNodes,
                    const device BuildingData* buildings,
                    const int buildingIndex) {
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    if (mapNode.data.x == 2) {
        character.addresses[0] = int4(buildingIndex, -1, -1, -1);
        character.navigation.x = -1;
        character.navigation.y = 3;
    } else if (mapNode.data.x == 1) {
        character.navigation.x = findNearestInternalEntrance(character, mapNodes, buildings,
                                                             buildingIndex);
        character.navigation.y = 2;
    } else {
        character.navigation.x = findNearestExternalEntrance(character, mapNodes, buildings,
                                                             buildingIndex);
        character.navigation.y = 0;
    }
}

// define the function that updates the navigation data of a character
void updateNavigation(thread CharacterData& character,
                      const device MapNodeData* mapNodes,
                      const device BuildingData* buildings,
                      const int buildingIndex,
                      const int mapNodeIndex,
                      const float3 randomNumber) {
    if (character.addresses[0].x >= 0 && character.addresses[0].x != buildingIndex) {
        exitCurrentBuilding(character, mapNodes, buildings);
    } else if (buildingIndex >= 0 && character.addresses[0].x == -1) {
        moveToBuilding(character, mapNodes, buildings, buildingIndex);
    } else if (buildingIndex >= 0 && character.addresses[0].x == buildingIndex) {
        character.navigation.x = mapNodeIndex;
        character.navigation.y = 3;
    }
    float4 destinationVector;
    if (character.navigation.x >= 0) {
        destinationVector = normalize(mapNodes[character.navigation.x].position - character.position);
    }
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    int connections[16];
    int connectionCount = 0;
    int desiredConnections[16];
    int desiredConnectionCount = 0;
    for (int index = 0; index < mapNode.data.w; index += 1) {
        const int connection = mapNode.connections[index];
        const MapNodeData currentMapNode = mapNodes[connection];
        if (connection == character.navigation.x) {
            character.navigation.w = character.navigation.z;
            character.navigation.z = connection;
            character.navigation.y = -1;
            character.navigation.x = -1;
            character.destination.xyz = currentMapNode.position.xyz;
            character.destination.x += (2.0f * randomNumber.x - 1.0f) * currentMapNode.dimension.x * 0.3f;
            character.destination.z += (2.0f * randomNumber.z - 1.0f) * currentMapNode.dimension.z * 0.3f;
            return;
        }
        if (character.navigation.y >= 0) {
            if (connection != character.navigation.w && currentMapNode.data.x == character.navigation.y) {
                connections[connectionCount] = connection;
                connectionCount += 1;
                if (character.navigation.x >= 0) {
                    const float4 vector = normalize(currentMapNode.position - character.position);
                    if (dot(destinationVector.xz, vector.xz) > 0.3f) {
                        desiredConnections[desiredConnectionCount] = connection;
                        desiredConnectionCount += 1;
                    }
                }
            }
        } else if (connection != character.navigation.w) {
            connections[connectionCount] = connection;
            connectionCount += 1;
            if (character.navigation.x >= 0) {
                const float4 vector = normalize(currentMapNode.position - character.position);
                if (dot(destinationVector.xz, vector.xz) > 0.3f) {
                    desiredConnections[desiredConnectionCount] = connection;
                    desiredConnectionCount += 1;
                }
            }
        }
    }
    if (desiredConnectionCount > 0) {
        character.navigation.w = character.navigation.z;
        character.navigation.z = desiredConnections[
            int(float(desiredConnectionCount) * fract(randomNumber.y))
        ];
        const MapNodeData currentMapNode = mapNodes[character.navigation.z];
        character.destination.xyz = currentMapNode.position.xyz;
        character.destination.x += (2.0f * randomNumber.x - 1.0f) * currentMapNode.dimension.x * 0.3f;
        character.destination.z += (2.0f * randomNumber.z - 1.0f) * currentMapNode.dimension.z * 0.3f;
        return;
    }
    if (connectionCount > 0) {
        character.navigation.w = character.navigation.z;
        character.navigation.z = connections[
            int(float(connectionCount) * fract(randomNumber.y))
        ];
        const MapNodeData currentMapNode = mapNodes[character.navigation.z];
        character.destination.xyz = currentMapNode.position.xyz;
        character.destination.x += (2.0f * randomNumber.x - 1.0f) * currentMapNode.dimension.x * 0.3f;
        character.destination.z += (2.0f * randomNumber.z - 1.0f) * currentMapNode.dimension.z * 0.3f;
        return;
    }
    const int previousMapNodeIndex = character.navigation.w;
    character.navigation.w = character.navigation.z;
    character.navigation.z = previousMapNodeIndex;
    const MapNodeData currentMapNode = mapNodes[character.navigation.z];
    character.destination.xyz = currentMapNode.position.xyz;
    character.destination.x += (2.0f * randomNumber.x - 1.0f) * currentMapNode.dimension.x * 0.3f;
    character.destination.z += (2.0f * randomNumber.z - 1.0f) * currentMapNode.dimension.z * 0.3f;
    return;
}

// define the function that updates the character movement
float3 updateMovement(thread CharacterData& character, constant FrameData& frame) {
    const float speedOffset = character.movement.y - character.movement.x;
    const float speedFactor = frame.data.y * characterMovementDampingFactor;
    character.movement.x += clamp(speedOffset * speedFactor,
                                  -characterMovementDampingFactor,
                                  characterMovementDampingFactor);
    const float4 targetDirection = normalize(character.destination - character.position);
    character.movement.w = atan2(targetDirection.z, targetDirection.x);
    while (character.movement.w - character.movement.z > PI) {
        character.movement.w -= PI * 2.0f;
    }
    while (character.movement.z - character.movement.w > PI) {
        character.movement.w += PI * 2.0f;
    }
    const float rotationOffset = character.movement.w - character.movement.z;
    const float rotationFactor = frame.data.y * characterMovementDampingFactor;
    character.movement.z += clamp(rotationOffset * rotationFactor,
                                  -characterMovementDampingFactor,
                                  characterMovementDampingFactor);
    const float directionX = cos(character.movement.z);
    const float directionZ = sin(character.movement.z);
    const float3 currentDirection = normalize(float3(directionX, 0.0f, directionZ));
    return currentDirection * character.movement.x * frame.data.y;
}

// define the function that updates the character movement with a specific position and rotation
void updateMovement(thread CharacterData& character, constant FrameData& frame,
                    const float4 position, const float rotation) {
    character.movement.w = rotation;
    while (character.movement.w - character.movement.z > PI) {
        character.movement.w -= PI * 2.0f;
    }
    while (character.movement.z - character.movement.w > PI) {
        character.movement.w += PI * 2.0f;
    }
    const float rotationOffset = character.movement.w - character.movement.z;
    const float rotationFactor = frame.data.y * characterMovementDampingFactor;
    character.movement.z += clamp(rotationOffset * rotationFactor,
                                  -characterMovementDampingFactor,
                                  characterMovementDampingFactor);
    const float3 positionOffset = position.xyz - character.position.xyz;
    const float positionFactor = frame.data.y * characterMovementDampingFactor;
    character.position.xyz += positionOffset * positionFactor;
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
    
    // acquire the current map node
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    
    // compute three random numbers based on the character position
    const float3 randomNumber = generateRandomNumber(character.position.xyz + float3(currentTime + float(index)));
    
    // compute the motion speed factor based on the character age
    const float motionSpeedFactor = (1.0f - pow(float(character.data.y) - 30.0f, 2.0f) * 0.01f) * 0.4f + 0.8f;
    
    // compute the scale factor based on the character age
    const float scaleFactor = 0.6f + float(character.data.y) * 0.01f;
    
    // define the variable of the index of the target building the character wants to move to
    int targetBuildingIndex = -1;
    
    // define the variable of the index of the target map node the character wants to move to
    int targetMapNodeIndex = -1;
    
    // update the character's stats
    const float sleepingFactor = (character.states.x == 1 && character.states.y == 2) ? 1.0f : 0.0f;
    character.stats[0] -= character.stats[2] * (1.0f - sleepingFactor) * frame.data.y;
    
    // update the character's goal based on the character's stats
    if (character.states.y == 0) {
        if (character.stats[0] < 0.0f) {
            character.states.x = 1;
        }
        if (character.stats[4] < character.stats[5]) {
            character.states.x = 2;
        }
    }
    
    // achieve the character's goal
    switch (character.states.x) {
            
            // sleeping
        case 1:
            
            // update the target building and map node indices
            targetBuildingIndex = character.addresses[1].x;
            targetMapNodeIndex = character.addresses[1].y;
            
            // perform the sleeping behavior when the character has arrived at the bed
            if (mapNode.data.x == 4 && length(character.destination - character.position) < 0.25f) {
                if (character.states.y < 2) {
                    character.states.y = 2;
                    character.movement.y = 0.0f;
                    updateMotion(character, 0, motionSpeedFactor, 0.0f, currentTime);
                    updateMotion(character, 1, 1.0f, 1.0f, currentTime);
                    updateMotion(character, 2, 1.0f, 1.0f, currentTime);
                } else if (character.states.y == 2) {
                    character.stats[0] += character.stats[1];
                    if (character.stats[0] > 1.0f) {
                        character.states.y = 3;
                        updateMotion(character, 1, 1.0f, 0.0f, currentTime);
                        updateMotion(character, 3, 1.0f, 1.0f, currentTime);
                    }
                } else if (character.states.y == 3) {
                    if (motionDurationPlayed(character, 3, currentTime) > 2.0f) {
                        character.states.x = 0;
                        character.states.y = 0;
                        character.stats[4] = 0.0f;
                    }
                }
                
                // update the character's movement explicitly
                updateMovement(character, frame, character.destination, 
                               float(character.addresses[1].z) * PI * 0.5f);
                
                // store the new character data
                characters[index] = character;
                
                // avoid further execution
                return;
            }
            break;
            
            // working
        case 2:
            
            // update the target building and map node indices
            targetBuildingIndex = character.addresses[2].x;
            targetMapNodeIndex = character.addresses[2].y;
            
            // perform the working behavior when the character has arrived at the office
            if (mapNode.data.x == 5 && length(character.destination - character.position) < 0.25f) {
                if (character.states.y < 2) {
                    character.states.y = 2;
                    character.movement.y = 0.0f;
                    updateMotion(character, 0, motionSpeedFactor, 0.0f, currentTime);
                    updateMotion(character, 4, 1.0, 1.0f, currentTime);
                } else if (character.states.y == 2) {
                    character.stats[3] += character.stats[6];
                    character.stats[4] += character.stats[6];
                    if (character.stats[4] > character.stats[5]) {
                        character.states.y = 3;
                        updateMotion(character, 4, 1.0, 0.0f, currentTime);
                    }
                } else if (character.states.y == 3) {
                    if (motionDurationPlayed(character, 4, currentTime) > 0.4f) {
                        character.states.x = 0;
                        character.states.y = 0;
                    }
                }
                
                // update the character's movement explicitly
                updateMovement(character, frame, character.destination,
                               float(character.addresses[2].z) * PI * 0.5f);
                
                // store the new character data
                characters[index] = character;
                
                // avoid further execution
                return;
            }
            break;
    }
    
    // update navigation when the character reaches the destination
    if (length(character.destination - character.position) < 0.25f) {
        
        // perform navigation update
        updateNavigation(character, mapNodes, buildings, targetBuildingIndex, targetMapNodeIndex, randomNumber);
        
        // update the walk motion controller with the new parameters
        updateMotion(character, 0, motionSpeedFactor, 1.0f, currentTime);
        
        // update the target speed
        character.movement.y = motionSpeedFactor * scaleFactor * motionRelatedMovementSpeed[0];
    }
    
    // update the character movement
    float3 deltaPosition = updateMovement(character, frame);
    
    const float radius = 0.2f;
    const float3 position = character.position.xyz;
    
    const float gridLengthX = frame.gridLengthData.x;
    const float gridLengthZ = frame.gridLengthData.y;
    
    const uint gridDim = uint(sqrt(float(frame.gridData.x)));
    const float width = gridLengthX * gridDim;
    const float height = gridLengthZ * gridDim;
    
    const float3 gridCenter = float3(width / 2.0f, 0.0f, height / 2.0f);
    const float3 characterPosition = clamp(position + gridCenter,
                                           float3(0.0f, 0.0f, 0.0f),
                                           float3(width, 0.0f, height));
    
    const uint gridIndexX = uint(characterPosition.x / gridLengthX);
    const uint gridIndexZ = uint(characterPosition.z / gridLengthZ);
    const uint gridIndex = gridIndexX + gridIndexZ * gridDim;
    const uint startIndex = gridData[gridIndex].data.x;
    const uint endIndex = gridData[gridIndex].data.y;
    
    for (uint i = startIndex; i <= endIndex; i++) {
        
        const uint neighbourIndex = characterIndexBuffer[i];
        if (neighbourIndex == index) {
            continue;
        }
        
        const CharacterData neighbour = characters[neighbourIndex];
        if (neighbour.states.x == 1 && neighbour.states.y == 2) {
            continue;
        }
        
        const float3 neighbourPosition = neighbour.position.xyz;
        if (distance(neighbourPosition, position) >= radius * 2.0f) {
            continue;
        };
        
        float3 v = normalize(neighbourPosition - position);
        if (dot(normalize(deltaPosition), v) <= 0.0f) {
            continue;
        };
        
        v = float3(v.z, 0.0f, -v.x);
        deltaPosition = dot(deltaPosition, v) * v * frame.data.y + v * 0.01f;
    }
    
    character.position.xyz += deltaPosition;
    
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
    const float radius = -4.0f;
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
