
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// define the global constants
constant float PI = 3.1415926535f;
constant float characterMovementDampingFactor = 0.1f;
constant float characterNavigationCompletionDistance = 0.8f;
constant float rigidBodyCollisionRadius = 400.0f;
constant float characterCollisionRadius = 0.3f;
constant float characterCollisionTurbulenceFactor = 0.01f;
constant float characterSocializationDistance = 2.0f;
constant float characterSocializationFactor = 0.001f;
constant float characterModelScale = 0.01f;

// define the motion controller constants
constant uint motionCount = 9;
constant float motionDurations[motionCount] = {
    1.0f,
    1.0f,
    -2.0f,
    -2.0f,
    0.75f,
    8.0f,
    1.0f,
    1.0f,
    1.0f,
};
constant float motionAttacks[motionCount] = {
    0.4f,
    1.0f,
    0.4f,
    0.4f,
    0.4f,
    0.4f,
    0.4f,
    0.4f,
    0.4f,
};
constant float motionRelatedMovementSpeed[motionCount] = {
    0.0325f,
    0.0f,
    0.0f,
    0.0f,
    0.0f,
    0.0f,
    0.0225f,
    0.02f,
    0.0f,
};

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    float4 data;
    
    // define the grid count data
    //  - gridCountData.x = gridCount
    uint4 gridCountData;
    
    // define the grid length data
    //  - gridLengthData.x = gridLength
    float4 gridLengthData;
    
    // define the block count data
    //  - blockCountData.x = block count
    uint4 blockCountData;
    
    // define the block length data
    //  - blockLengthData.x = block side length
    //  - blockLengthData.y = block distance
    float4 blockLengthData;
    
    // define the character data
    //  - characterData.x = character count
    //  - characterData.y = visible character count
    //  - characterData.z = actual visible character count
    uint4 characterData;
    
    // define the position of the observer
    float4 observerPosition;
    
    // define the frustrum data
    float4 frustumData[6];
};

// define the character data
struct CharacterData {
    
    // define the integer data of the character
    //  - data.x = gender (0: female, 1: male)
    //  - data.y = age (20 - 40)
    uint4 data;
    
    // define the personalities of the character
    float4 personalities;
    
    // define the states of the character
    //  - states.x = goal
    //      - 0 = wandering on the street
    //      - 1 = sleeping (determined by energy)
    //      - 2 = working (determined by gold)
    //      - 3 = socializing (determined by socialization impulse)
    //  - states.y = goal planner state
    //  - states.z = target character
    uint4 states;
    
    // define the stats of the character
    //  - stats[0] = energy (restored by sleeping)
    //  - stats[1] = energy restoration
    //  - stats[2] = energy consumption
    //  - stats[3] = total gold
    //  - stats[4] = gold earned in the current cycle
    //  - stats[5] = target gold per cycle
    //  - stats[6] = gold earned per frame
    //  - stats[7] = socialization impulse
    //  - stats[8] = socialization impulse restoration
    //  - stats[9] = socialization impulse consumption
    //  - stats[10] = entertainment energy consumption
    float stats[12];
    
    // define the unique addresses of the character
    //  - addresses[0] = the current address
    //  - addresses[1] = the bed in the apartment
    //  - addresses[2] = the office in the office building
    //  - addresses[3] = the entertainment address
    int4 addresses[4];
    
    // define the navigation data of the character
    //  - navigation.x = the ultimate destination map node index
    //  - navigation.y = the desired map node type
    //  - navigation.z = the temporary destination map node index
    //  - navigation.w = the previous map node index
    int4 navigation;
    
    // define the navigation target of the character
    //  - target.x = the target building index
    //  - target.y = the target map node index
    //  - target.z = the desired target building index
    //  - target.w = the desired target node index
    int4 target;
    
    // define the current map node data
    int4 mapNodeData;
    
    // define the velocity of the character
    float4 velocity;
    
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
    float4x2 motionControllers[25];
};

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = gender
    //  - data.w = character node index
    uint4 data;
    
    // define the personalities of the character
    float4 personalities;
    
    // define the indices of the female mesh nodes
    float4 femaleMeshNodeIndices;
    
    // define the indices of the male mesh nodes
    float4 maleMeshNodeIndices;
    
    // define the transform of the visible character
    float4x4 transform;
    
    // define the motion controller indices
    int motionControllerIndices[25];
    
    // define the motion controllers
    float4x2 motionControllers[25];
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
    //      - 5 = office
    //      - 6 = treadmill
    //  - data.y = orientation
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
    //      - 1 = apartment
    //      - 2 = office
    //      - 3 = gym
    //  - data.z = capacity
    //  - data.w = entrance count
    int4 data;
    
    // define the position of the building
    float4 position;
    
    // define the quality of the building
    float4 quality;
    
    // define the external entrances of the building
    int externalEntrances[4];
    
    // define the internal entrances of the building
    int internalEntrances[4];

    // define the interactable nodes
    int interactableNodes[16];
    
    // define the interactable node availabilities
    int interactableNodeAvailabilities[16];
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
    float4x2 motionController = character.motionControllers[motionIndex];
    if (motionDurations[motionIndex] < 0.0f) {
        motionController[1][0] = 0.0f;
        motionController[1][1] = 0.0f;
        motionController[3][0] = currentTime;
        motionController[3][1] = currentTime;
    } else {
        const float offset = targetSpeed * (currentTime - motionController[3][1]);
        if (offset < motionAttacks[motionIndex]) {
            const float factor = 0.5f - cos(offset / motionAttacks[motionIndex] * PI) * 0.5f;
            motionController[1][0] = motionController[1][0] * (1.0 - factor) + motionController[1][1] * factor;
        } else {
            motionController[1][0] = motionController[1][1];
        }
    }
    const float progress = fmod(targetSpeed * (currentTime - motionController[3][0]), motionDurations[motionIndex]);
    motionController[0][0] = motionDurations[motionIndex];
    motionController[0][1] = -targetSpeed;
    motionController[1][1] = clamp(targetBlendWeight, 0.0001f, 1.0f);
    motionController[2][0] = motionAttacks[motionIndex];
    motionController[2][1] = motionAttacks[motionIndex];
    motionController[3][0] = currentTime - (motionController[1][0] <= 0.0001f ? 0.0f : progress) / targetSpeed;
    motionController[3][1] = currentTime;
    character.motionControllers[motionIndex] = motionController;
}

// defien the function that gets the duration played for a motion
float motionDurationPlayed(thread CharacterData& character, const int motionIndex,
                           const float currentTime) {
    const float4x2 motionController = character.motionControllers[motionIndex];
    return currentTime - motionController[3][1];
}

// define the function that finds the nearest external entrance of a building
int findExternalEntrance(thread CharacterData& character,
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

// define the function that finds the nearest internal entrance of a building
int findInternalEntrance(thread CharacterData& character,
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

// define the function that navigates the character to exit the building
void exitBuilding(thread CharacterData& character,
                  const device MapNodeData* mapNodes,
                  const device BuildingData* buildings) {
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    if (mapNode.data.x == 1) {
        character.addresses[0] = int4(-1);
        character.navigation.x = -1;
        character.navigation.y = 0;
    } else if (mapNode.data.x == 2) {
        character.navigation.x = findExternalEntrance(character, mapNodes, buildings, character.addresses[0].x);
        character.navigation.y = 1;
    } else {
        character.navigation.x = findInternalEntrance(character, mapNodes, buildings, character.addresses[0].x);
        character.navigation.y = 3;
    }
}

// implement the function that navigates the character to a building
void enterBuilding(thread CharacterData& character,
                   const device MapNodeData* mapNodes,
                   const device BuildingData* buildings,
                   const int buildingIndex) {
    const MapNodeData mapNode = mapNodes[character.navigation.z];
    if (mapNode.data.x == 2) {
        character.addresses[0] = int4(buildingIndex, -1, -1, -1);
        character.navigation.x = -1;
        character.navigation.y = 3;
    } else if (mapNode.data.x == 1) {
        character.navigation.x = findInternalEntrance(character, mapNodes, buildings, buildingIndex);
        character.navigation.y = 2;
    } else {
        character.navigation.x = findExternalEntrance(character, mapNodes, buildings, buildingIndex);
        character.navigation.y = 0;
    }
}

// define the function that updates the navigation data of a character
void updateNavigation(thread CharacterData& character,
                      const device MapNodeData* mapNodes,
                      const device BuildingData* buildings,
                      const float3 randomNumber) {
    if (character.addresses[0].x >= 0 && character.addresses[0].x != character.target.x) {
        exitBuilding(character, mapNodes, buildings);
    } else if (character.target.x >= 0 && character.addresses[0].x == -1) {
        enterBuilding(character, mapNodes, buildings, character.target.x);
    } else if (character.target.x >= 0 && character.addresses[0].x == character.target.x) {
        character.navigation.x = character.target.y;
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
    character.movement.x += clamp(speedOffset * speedFactor, -characterMovementDampingFactor, characterMovementDampingFactor);
    if (distance(character.destination, character.position) > 0.0f) {
        const float4 targetDirection = normalize(character.destination - character.position);
        character.movement.w = atan2(targetDirection.z, targetDirection.x);
        const float difference = fmod(character.movement.w - character.movement.z + PI, PI * 2.0f) - PI;
        character.movement.w = character.movement.z + (difference < PI ? difference + PI * 2.0f : difference);
        const float rotationOffset = character.movement.w - character.movement.z;
        const float rotationFactor = frame.data.y * characterMovementDampingFactor;
        character.movement.z += clamp(rotationOffset * rotationFactor, -characterMovementDampingFactor, characterMovementDampingFactor);
    }
    const float directionX = cos(character.movement.z);
    const float directionZ = sin(character.movement.z);
    const float3 currentDirection = normalize(float3(directionX, 0.0f, directionZ));
    return currentDirection * character.movement.x * frame.data.y;
}

// define the function that updates the character movement with a specific position and rotation
void updateMovement(thread CharacterData& character, constant FrameData& frame,
                    const float4 position, const float rotation) {
    character.movement.w = rotation;
    const float difference = fmod(character.movement.w - character.movement.z + PI, PI * 2.0f) - PI;
    character.movement.w = character.movement.z + (difference < PI ? difference + PI * 2.0f : difference);
    const float rotationOffset = character.movement.w - character.movement.z;
    const float rotationFactor = frame.data.y * characterMovementDampingFactor;
    character.movement.z += clamp(rotationOffset * rotationFactor, -characterMovementDampingFactor, characterMovementDampingFactor);
    const float3 positionOffset = position.xyz - character.position.xyz;
    const float positionFactor = frame.data.y * characterMovementDampingFactor;
    character.position.xyz += positionOffset * positionFactor;
}

// define the simulation function
kernel void SimulationFunction(constant FrameData& frame [[buffer(0)]],
                               device CharacterData* characters [[buffer(1)]],
                               device atomic<uint>* characterCount [[buffer(2)]],
                               device uint* physicsSimulationCharacterIndices [[buffer(3)]],
                               device uint* navigationCharacterIndices [[buffer(4)]],
                               device uint* socializationCharacterIndices [[buffer(5)]],
                               device uint* entertainmentEntranceCharacterIndices [[buffer(6)]],
                               device uint* entertainmentExitCharacterIndices [[buffer(7)]],
                               const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // acquire the current time
    const float currentTime = frame.data.x;
    
    // acquire the current character
    CharacterData character = characters[index];
    
    // compute the motion speed factor based on the character age
    const float motionSpeedFactor = (1.0f - pow(float(character.data.y) - 30.0f, 2.0f) * 0.01f) * 0.4f + 0.8f;
    
    // update the character's stats
    const float energyRestorationFactor = (character.states.x == 1 && character.states.y == 2) ? 1.0f : 0.0f;
    character.stats[0] += character.stats[1] * energyRestorationFactor * frame.data.y;
    float energyConsumptionFactor = 1.0f;
    energyConsumptionFactor *= (character.states.x == 1 && character.states.y == 2) ? 0.0f : 1.0f;
    energyConsumptionFactor *= (character.states.x == 2) ? 0.0f : 1.0f;
    energyConsumptionFactor *= (character.states.x == 4 && character.states.y == 2) ? 1.0f : 0.0f;
    float baseEnergyConsumption = (character.states.x == 4) ? character.stats[10] : character.stats[2];
    character.stats[0] -= baseEnergyConsumption * energyConsumptionFactor * frame.data.y;
    const float goldRestorationFactor = (character.states.x == 2 && character.states.y == 2) ? 1.0f : 0.0f;
    character.stats[3] += character.stats[6] * goldRestorationFactor * frame.data.y;
    character.stats[4] += character.stats[6] * goldRestorationFactor * frame.data.y;
    const float socializationImpulseRestorationFactor = (character.states.x == 0) ? 1.0f : 0.0f;
    character.stats[7] += character.stats[8] * socializationImpulseRestorationFactor * frame.data.y;
    const float socializationImpulseConsumptionFactor = (character.states.x == 3 && character.states.y == 2) ? 1.0f : 0.0f;
    character.stats[7] -= character.stats[9] * socializationImpulseConsumptionFactor * frame.data.y;
    
    // update the character's goal based on the character's stats
    character.states.x = (character.states.y == 0 && character.stats[0] < 0.0f) ? 1 : character.states.x;
    character.states.x = (character.states.y == 0 && character.stats[4] < character.stats[5]) ? 2 : character.states.x;
    
    // reset the character's navigation target
    character.target = int4(-1);
    
    // achieve the character's goal
    switch (character.states.x) {
            
            // sleeping
        case 1:
            
            // update the character's navigation target
            character.target = character.addresses[1];
            
            // perform the sleeping behavior when the character has arrived at the bed
            if (character.mapNodeData.x == 4 && length(character.destination - character.position) < characterNavigationCompletionDistance) {
                if (character.states.y < 2) {
                    character.states.y = 2;
                    character.movement.y = 0.0f;
                    updateMotion(character, 7, motionSpeedFactor, 0.0f, currentTime);
                    updateMotion(character, 1, 1.0f, 1.0f, currentTime);
                    updateMotion(character, 2, 1.0f, 1.0f, currentTime);
                } else if (character.states.y == 2) {
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
            
            // update the character's navigation target
            character.target = character.addresses[2];
            
            // perform the working behavior when the character has arrived at the office
            if (character.mapNodeData.x == 5 && length(character.destination - character.position) < characterNavigationCompletionDistance) {
                if (character.states.y < 2) {
                    character.states.y = 2;
                    character.movement.y = 0.0f;
                    updateMotion(character, 0, motionSpeedFactor, 0.0f, currentTime);
                    updateMotion(character, 4, 1.0, 1.0f, currentTime);
                } else if (character.states.y == 2) {
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
            
            // socializing
        case 3: {
            if (character.states.y < 2) {
                character.states.y = 2;
                updateMotion(character, 6, motionSpeedFactor, 0.0f, currentTime);
                updateMotion(character, 5, motionSpeedFactor, 1.0f, currentTime);
            } else if (character.states.y == 2) {
                const float4 targetCharacterPosition = characters[character.states.z].position;
                const float targetCharacterDistance = distance(targetCharacterPosition, character.position);
                if (character.stats[7] < 0.0f || characters[character.states.z].states.x != 3) {
                    character.states.y = 3;
                } else if (targetCharacterDistance > 0.0f) {
                    const float4 targetDirection = normalize(targetCharacterPosition - character.position);
                    float targetAngle = atan2(targetDirection.z, targetDirection.x);
                    targetAngle += character.movement.z - targetAngle > PI ? PI * 2.0f : 0.0f;
                    targetAngle += character.movement.z - targetAngle > PI ? PI * 2.0f : 0.0f;
                    targetAngle -= targetAngle - character.movement.z > PI ? PI * 2.0f : 0.0f;
                    targetAngle -= targetAngle - character.movement.z > PI ? PI * 2.0f : 0.0f;
                    const float rotationOffset = targetAngle - character.movement.z;
                    const float rotationFactor = frame.data.y * characterMovementDampingFactor;
                    character.movement.z += clamp(rotationOffset * rotationFactor, -characterMovementDampingFactor, characterMovementDampingFactor);
                }
                const float4 targetCharacterPersonalities = characters[character.states.z].personalities;
                const float4 offset = targetCharacterPersonalities - character.personalities;
                if (length(offset) > 0.0f) {
                    character.personalities += normalize(offset) * characterSocializationFactor * frame.data.y;
                    character.personalities = normalize(character.personalities);
                }
            } else if (character.states.y == 3) {
                character.states.x = 0;
                character.states.y = 0;
                character.stats[7] = 0.0f;
                updateMotion(character, 6, motionSpeedFactor, 1.0f, currentTime);
                updateMotion(character, 5, motionSpeedFactor, 0.0f, currentTime);
            }
            
            // store the new character data
            characters[index] = character;
            
            // avoid further execution
            return;
        }
            
            // entertaining
        case 4: {
            
            // update the character's navigation target
            character.target = character.addresses[3];
            if (character.mapNodeData.x == 6 && length(character.destination - character.position) < characterNavigationCompletionDistance) {
                if (character.states.y < 2) {
                    character.states.y = 2;
                    updateMotion(character, 6, motionSpeedFactor, 0.0f, currentTime);
                    updateMotion(character, 8, motionSpeedFactor, 1.0f, currentTime);
                } else if (character.states.y == 2) {
                    if (character.stats[0] < 0.0f) {
                        character.states.y = 3;
                        updateMotion(character, 8, motionSpeedFactor, 0.0f, currentTime);
                    }
                } else if (character.states.y == 3) {
                    break;
                }
                
                // update the character's movement explicitly
                updateMovement(character, frame, character.destination,
                               float(character.mapNodeData.y) * PI * 0.5f);
                
                // store the new character data
                characters[index] = character;
                
                // avoid further execution
                return;
            }
            break;
        }
            
    }
    
    // update the character position
    character.position.xyz += character.velocity.xyz;
    
    // update the character movement
    character.velocity.xyz = updateMovement(character, frame);
    
    // store the new character data
    characters[index] = character;
    
    // store the current character index for physics simulation
    if (distance(character.position.xz, frame.observerPosition.xz) < rigidBodyCollisionRadius) {
        const uint count = atomic_fetch_add_explicit(&characterCount[0], 1, memory_order_relaxed);
        physicsSimulationCharacterIndices[count] = index;
    }
    
    // store the current character index for navigation
    if (length(character.destination - character.position) < characterNavigationCompletionDistance * 0.8f) {
        const uint count = atomic_fetch_add_explicit(&characterCount[1], 1, memory_order_relaxed);
        navigationCharacterIndices[count] = index;
    }
    
    // store the current character index for socialization
    if (character.states.x == 0 && character.stats[7] > 1.0f) {
        const uint count = atomic_fetch_add_explicit(&characterCount[2], 1, memory_order_relaxed);
        socializationCharacterIndices[count] = index;
    }
    
    // store the current character index for possible entertainment building entrance
    if (character.states.x == 0 && character.stats[0] > 0.0f) {
        const uint count = atomic_fetch_add_explicit(&characterCount[3], 1, memory_order_relaxed);
        entertainmentEntranceCharacterIndices[count] = index;
    }
    
    // store the current character index for possible entertainment building exit
    if (character.states.x == 4 && character.stats[0] < 0.0f) {
        const uint count = atomic_fetch_add_explicit(&characterCount[4], 1, memory_order_relaxed);
        entertainmentExitCharacterIndices[count] = index;
    }
}

// define the physics simulation function
kernel void InitializeIndirectBufferFunction(const device uint* characterCount [[buffer(0)]],
                                             device MTLDispatchThreadsIndirectArguments* arguments [[buffer(1)]],
                                             const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of indirect buffers
    if (index >= 10) {
        return;
    }
    
    // initialize the output arguments
    MTLDispatchThreadsIndirectArguments outputArguments;
    outputArguments.threadsPerGrid[0] = characterCount[index] / 64 + 1;
    outputArguments.threadsPerGrid[1] = 1;
    outputArguments.threadsPerGrid[2] = 1;
    outputArguments.threadsPerThreadgroup[0] = 64;
    outputArguments.threadsPerThreadgroup[1] = 1;
    outputArguments.threadsPerThreadgroup[2] = 1;
    
    // store the output arguments
    arguments[index] = outputArguments;
}

// define the physics simulation function
kernel void PhysicsSimulationFunction(constant FrameData& frame [[buffer(0)]],
                                      device CharacterData* characters [[buffer(1)]],
                                      const device uint* characterCount [[buffer(2)]],
                                      const device uint* physicsSimulationCharacterIndices [[buffer(3)]],
                                      const device GridData* gridData [[buffer(4)]],
                                      const device uint* characterIndexBuffer [[buffer(5)]],
                                      const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= characterCount[0]) {
        return;
    }
    
    // acquire the character index
    const uint characterIndex = physicsSimulationCharacterIndices[index];
    
    // acquire the current character
    CharacterData character = characters[characterIndex];
    
    // compute the scale factor based on the character age
    const float scaleFactor = 0.6f + float(character.data.y) * 0.01f;
    
    // compute the grid coordinate based on the character position
    const float2 gridSize = float2(frame.gridLengthData.x * float(frame.gridCountData.x));
    const float2 gridCenter = gridSize * 0.5f;
    const float2 gridPosition = clamp(character.position.xz + gridCenter, float2(0.0f), gridSize);
    const uint2 gridCoordinate = uint2(gridPosition / frame.gridLengthData.x);
    
    // compute the grid coordinate boundaries
    const uint2 minGridCoordinate = uint2(max(int2(gridCoordinate) - 1, 0));
    const uint2 maxGridCoordinate = uint2(min(int2(gridCoordinate) + 1, int2(frame.gridCountData.x) - 1));
    
    // iterate through all the neighbor grids
    for (uint x = minGridCoordinate.x; x <= maxGridCoordinate.x; x += 1) {
        for (uint y = minGridCoordinate.y; y <= maxGridCoordinate.y; y += 1) {
            
            // compute the grid index
            const uint gridIndex = x + y * frame.gridCountData.x;
            
            // acquire the iteration boundaries index
            const uint2 iterationBoundaries = gridData[gridIndex].data.xy;
            
            // iterate through all the characters in the grid
            for (uint currentIndex = iterationBoundaries.x; currentIndex < iterationBoundaries.y; currentIndex += 1) {
                const uint neighborIndex = characterIndexBuffer[currentIndex];
                if (neighborIndex == characterIndex) {
                    continue;
                }
                const uint4 neighborStates = characters[neighborIndex].states;
                if (neighborStates.x == 1 && neighborStates.y == 2) {
                    continue;
                }
                if (neighborStates.x == 2 && neighborStates.y == 2) {
                    continue;
                }
                const float3 neighborPosition = characters[neighborIndex].position.xyz;
                const float neighborScaleFactor = 0.6f + float(characters[neighborIndex].data.y) * 0.01f;
                const float targetDistance = characterCollisionRadius * scaleFactor + characterCollisionRadius * neighborScaleFactor;
                if (distance(neighborPosition, character.position.xyz) >= targetDistance) {
                    continue;
                };
                float3 vector = normalize(neighborPosition - character.position.xyz);
                if (dot(normalize(character.velocity.xyz), vector) <= 0.0f) {
                    continue;
                };
                vector = float3(vector.z, 0.0f, -vector.x);
                character.velocity.xyz = dot(character.velocity.xyz, vector) * vector * frame.data.y + vector * characterCollisionTurbulenceFactor;
            }
        }
    }
    
    // store the new character data
    characters[characterIndex].velocity.xyz = character.velocity.xyz;
}

// define the navigation function
kernel void NavigationFunction(constant FrameData& frame [[buffer(0)]],
                               device CharacterData* characters [[buffer(1)]],
                               const device uint* characterCount [[buffer(2)]],
                               const device uint* navigationCharacterIndices [[buffer(3)]],
                               const device MapNodeData* mapNodes [[buffer(4)]],
                               const device BuildingData* buildings [[buffer(5)]],
                               const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= characterCount[1]) {
        return;
    }
    
    // acquire the character index
    const uint characterIndex = navigationCharacterIndices[index];
    
    // acquire the current time
    const float currentTime = frame.data.x;
    
    // acquire the current character
    CharacterData character = characters[characterIndex];
    
    // compute three random numbers based on the character position
    const float3 randomNumber = generateRandomNumber(character.position.xyz + float3(currentTime + float(index)));
    
    // compute the motion speed factor based on the character age
    const float motionSpeedFactor = (1.0f - pow(float(character.data.y) - 30.0f, 2.0f) * 0.01f) * 0.4f + 0.8f;
    
    // compute the scale factor based on the character age
    const float scaleFactor = 0.6f + float(character.data.y) * 0.01f;
    
    // perform navigation update
    updateNavigation(character, mapNodes, buildings, randomNumber);
    
    // update the walk motion controller with the new parameters and the target speed
    if (character.states.x == 2) {
        updateMotion(character, 0, motionSpeedFactor, 1.0f, currentTime);
        updateMotion(character, 6, motionSpeedFactor, 0.0f, currentTime);
        updateMotion(character, 7, motionSpeedFactor, 0.0f, currentTime);
        character.movement.y = motionSpeedFactor * scaleFactor * motionRelatedMovementSpeed[0];
    } else if (character.states.x == 1) {
        updateMotion(character, 0, motionSpeedFactor, 0.0f, currentTime);
        updateMotion(character, 6, motionSpeedFactor, 0.0f, currentTime);
        updateMotion(character, 7, motionSpeedFactor, 1.0f, currentTime);
        character.movement.y = motionSpeedFactor * scaleFactor * motionRelatedMovementSpeed[7];
    } else {
        updateMotion(character, 0, motionSpeedFactor, 0.0f, currentTime);
        updateMotion(character, 6, motionSpeedFactor, 1.0f, currentTime);
        updateMotion(character, 7, motionSpeedFactor, 0.0f, currentTime);
        character.movement.y = motionSpeedFactor * scaleFactor * motionRelatedMovementSpeed[6];
    }
    
    // update the current map node data
    character.mapNodeData = mapNodes[character.navigation.z].data;
    
    // store the new character data
    characters[characterIndex] = character;
}

// define the socialization function
kernel void SocializationFunction(constant FrameData& frame [[buffer(0)]],
                                  device CharacterData* characters [[buffer(1)]],
                                  const device uint* characterCount [[buffer(2)]],
                                  const device uint* socializationCharacterIndices [[buffer(3)]],
                                  const device GridData* gridData [[buffer(4)]],
                                  const device uint* characterIndexBuffer [[buffer(5)]],
                                  const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= characterCount[2]) {
        return;
    }
    
    // acquire the character index
    const uint characterIndex = socializationCharacterIndices[index];
    
    // acquire the current character
    CharacterData character = characters[characterIndex];
    
    // compute the grid coordinate based on the character position
    const float2 gridSize = float2(frame.gridLengthData.x * float(frame.gridCountData.x));
    const float2 gridCenter = gridSize * 0.5f;
    const float2 gridPosition = clamp(character.position.xz + gridCenter, float2(0.0f), gridSize);
    const uint2 gridCoordinate = uint2(gridPosition / frame.gridLengthData.x);
    
    // compute the grid coordinate boundaries
    const uint2 minGridCoordinate = uint2(max(int2(gridCoordinate) - 1, 0));
    const uint2 maxGridCoordinate = uint2(min(int2(gridCoordinate) + 1, int2(frame.gridCountData.x) - 1));
    
    // iterate through all the neighbor grids
    for (uint x = minGridCoordinate.x; x <= maxGridCoordinate.x; x += 1) {
        for (uint y = minGridCoordinate.y; y <= maxGridCoordinate.y; y += 1) {
            
            // compute the grid index
            const uint gridIndex = x + y * frame.gridCountData.x;
            
            // acquire the iteration boundaries index
            const uint2 iterationBoundaries = gridData[gridIndex].data.xy;
            
            // iterate through all the characters in the grid
            for (uint currentIndex = iterationBoundaries.x; currentIndex < iterationBoundaries.y; currentIndex += 1) {
                const uint neighborIndex = characterIndexBuffer[currentIndex];
                if (neighborIndex == characterIndex) {
                    continue;
                }
                if (characters[neighborIndex].states.x != 0 || characters[neighborIndex].stats[7] > 1.0f) {
                    continue;
                }
                if (dot(character.personalities.xyz, characters[neighborIndex].personalities.xyz) < 0.0f) {
                    continue;
                }
                const float3 neighborPosition = characters[neighborIndex].position.xyz;
                if (distance(neighborPosition, character.position.xyz) >= characterSocializationDistance) {
                    continue;
                };
                characters[characterIndex].states = uint4(3, 0, neighborIndex, 0);
                characters[characterIndex].stats[7] = 1.0f;
                characters[neighborIndex].states = uint4(3, 0, characterIndex, 0);
                characters[neighborIndex].stats[7] = 1.0f;
                return;
            }
        }
    }
    
    // store the new character data
    characters[characterIndex].stats[7] -= 0.1f;
}

// define the ind closest entertainment building function
int findClosestEntertainmentBuilding(constant FrameData& frame, const device BuildingData* buildings, float3 characterPosition, float3 characterPersonality) {
    
    // aquire the block data
    const uint blockCount = frame.blockCountData.x;
    const float blockSideLength = frame.blockLengthData.x;
    const float blockDistance = frame.blockLengthData.y;
    const float blockLength = blockCount * blockSideLength;
    const float intervalLength = blockCount * blockDistance;
    const float2 origin = float2((blockLength + intervalLength) * 0.5f);
    
    // compute the building index based on the character position
    const float2 position = characterPosition.xz;
    const float2 centeredPosition = clamp(position + origin, float2(0.0f), float2(blockLength + intervalLength));
    const uint2 buildingCoordinate = uint2(centeredPosition / (blockSideLength + blockDistance));
    const uint buildingIndex = buildingCoordinate.x * blockCount + buildingCoordinate.y;
    
    // compute the building coordinate boundaries
    const uint2 minBuildingCoordinate = uint2(max(int2(buildingCoordinate) - 1, 0));
    const uint2 maxBuildingCoordinate = uint2(min(int2(buildingCoordinate) + 1, int2(frame.blockCountData.x) - 1));
    
    float distance = FLT_MAX;
    int closestBuildingIndex = -1;
    
    // iterate through all the neighbor buildings
    for (uint x = minBuildingCoordinate.x; x <= maxBuildingCoordinate.x; x += 1) {
        for (uint y = minBuildingCoordinate.y; y <= maxBuildingCoordinate.y; y += 1) {
            
            // compute the building index
            const uint neighborIndex = x * blockCount + y;
            BuildingData neighborBuilding = buildings[neighborIndex];
            if (neighborIndex == buildingIndex) {
                continue;
            }
            
            if (neighborBuilding.data.x == 3 && dot(neighborBuilding.quality.xyz, characterPersonality) > 0.0f) {
                const float distanceToNeighbor = length(characterPosition - neighborBuilding.position.xyz);
                if (distanceToNeighbor < distance) {
                    distance = distanceToNeighbor;
                    closestBuildingIndex = neighborIndex;
                }
            }
        }
    }
    return closestBuildingIndex;
}

// define the entertainment entrance function
kernel void EntertianmentEntranceFunction(constant FrameData& frame [[buffer(0)]],
                                                  device CharacterData* characters [[buffer(1)]],
                                                  const device uint* characterCount [[buffer(2)]],
                                                  const device uint* entertainmentEntranceCharacterIndices [[buffer(3)]],
                                                  device BuildingData* buildings [[buffer(4)]],
                                                  device atomic<uint>* characterCountPerBuilding [[buffer(5)]],
                                                  const uint index [[thread_position_in_grid]]) {
                                                      
    // avoid execution when the index exceeds the total number of characters
    if (index >= characterCount[3]) {
        return;
    }
    
    // acquire the character index
    const uint characterIndex = entertainmentEntranceCharacterIndices[index];
    
    // acquire the current character
    CharacterData character = characters[characterIndex];
    const int closestEntertainmentBuildingIndex = findClosestEntertainmentBuilding(frame, buildings, character.position.xyz, character.personalities.xyz);
    if (closestEntertainmentBuildingIndex != -1) {
        BuildingData targetBuilding = buildings[closestEntertainmentBuildingIndex];
        const uint count = atomic_fetch_add_explicit(&characterCountPerBuilding[closestEntertainmentBuildingIndex], 1, memory_order_relaxed);
        if (count == 0) {
            for (int i = 0; i < targetBuilding.data.z; i += 1) {
                if (targetBuilding.interactableNodeAvailabilities[i] == 1) {
                    character.addresses[3] = int4(closestEntertainmentBuildingIndex, targetBuilding.interactableNodes[i], -1, 0);
                    targetBuilding.interactableNodeAvailabilities[i] = 0;
                    buildings[closestEntertainmentBuildingIndex] = targetBuilding;
                    character.states.x = 4;
                    character.states.y = 0;
                    characters[characterIndex] = character;
                    break;
                }
            }
        }
    }
}

// define the entertainment exit function
kernel void EntertianmentExitFunction(constant FrameData& frame [[buffer(0)]],
                                      device CharacterData* characters [[buffer(1)]],
                                      const device uint* characterCount [[buffer(2)]],
                                      const device uint* entertainmentExitCharacterIndices [[buffer(3)]],
                                      device BuildingData* buildings [[buffer(4)]],
                                      const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= characterCount[4]) {
        return;
    }
    
    // acquire the character index
    const uint characterIndex = entertainmentExitCharacterIndices[index];
    
    // acquire the current character
    CharacterData character = characters[characterIndex];
    BuildingData targetBuilding = buildings[character.target.x];
    for (int i = 0; i < targetBuilding.data.z; i += 1) {
        if (targetBuilding.interactableNodes[i] == character.target.y) {
            targetBuilding.interactableNodeAvailabilities[i] = 1;
            buildings[character.target.x] = targetBuilding;
            character.addresses[3] = int4(-1);
            character.states.x = 1;
            character.states.y = 0;
            characters[characterIndex] = character;
            break;
        }
    }
}

// define the compute grid function
kernel void ComputeGridFunction(constant FrameData& frame [[buffer(0)]],
                                const device CharacterData* characters [[buffer(1)]],
                                device atomic<uint>* characterCountPerGrid [[buffer(2)]],
                                const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // acquire the current character position
    const float2 position = characters[index].position.xz;
    
    // compute the grid index based on the character position
    const float2 gridSize = float2(frame.gridLengthData.x * float(frame.gridCountData.x));
    const float2 gridCenter = gridSize * 0.5f;
    const float2 gridPosition = clamp(position + gridCenter, float2(0.0f), gridSize);
    const uint2 gridCoordinate = uint2(gridPosition / frame.gridLengthData.x);
    const uint gridIndex = gridCoordinate.x + gridCoordinate.y * frame.gridCountData.x;
    
    // increase the character count of the current grid
    atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
}

// define the initialize grid function
kernel void InitializeGridFunction(constant FrameData& frame [[buffer(0)]],
                                   const device uint* characterCountPerGrid [[buffer(1)]],
                                   device GridData* gridData [[buffer(2)]],
                                   device atomic<uint>* nextAvailableGridIndex [[buffer(3)]],
                                   const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of map grids
    if (index >= frame.gridCountData.x * frame.gridCountData.x) {
        return;
    }
    
    // acquire the character count of the current grid
    const uint characterCount = characterCountPerGrid[index];
    
    // compute the start index
    const uint startIndex = atomic_fetch_add_explicit(&nextAvailableGridIndex[0], characterCount, memory_order_relaxed);
    
    // initialize the current grid
    gridData[index].data.x = startIndex;
    gridData[index].data.y = startIndex + characterCount;
}

// define the set character index per grid
kernel void SetCharacterIndexPerGridFunction(constant FrameData& frame [[buffer(0)]],
                                             const device CharacterData* characters [[buffer(1)]],
                                             device atomic<uint>* characterCountPerGrid [[buffer(2)]],
                                             device uint* characterIndexBuffer [[buffer(3)]],
                                             const device GridData* gridData [[buffer(4)]],
                                             const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // acquire the current character position
    const float2 position = characters[index].position.xz;
    
    // compute the grid index based on the character position
    const float2 gridSize = float2(frame.gridLengthData.x * float(frame.gridCountData.x));
    const float2 gridCenter = gridSize * 0.5f;
    const float2 gridPosition = clamp(position + gridCenter, float2(0.0f), gridSize);
    const uint2 gridCoordinate = uint2(gridPosition / frame.gridLengthData.x);
    const uint gridIndex = gridCoordinate.x + gridCoordinate.y * frame.gridCountData.x;
    
    // increase the character count of the current grid
    const uint characterCount = atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
    
    // store the character index
    characterIndexBuffer[gridData[gridIndex].data.x + characterCount] = index;
}

// define the find visible characters function
kernel void FindVisibleCharactersFunction(constant FrameData& frame [[buffer(0)]],
                                          const device CharacterData* characters [[buffer(1)]],
                                          device atomic<uint>* visibleCharacterCount [[buffer(2)]],
                                          device uint* potentiallyVisibleCharacterIndexBuffer [[buffer(3)]],
                                          device float* visibleCharacterDistanceToObserverBuffer [[buffer(4)]],
                                          const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // perform frustum culling
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
    
    // mark the character as potentially visible
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
    
    // acquire the character index
    const uint characterIndex = visibleCharacterIndexBuffer[index];
    
    // acquire the character
    const CharacterData character = characters[characterIndex];
    
    // update the visible character based on the current character
    VisibleCharacterData visibleCharacter;
    visibleCharacter.data.x = character.data.x;
    visibleCharacter.personalities.xyz = character.personalities.xyz;
    const float matrixAngle = PI * 0.5f - character.movement.z;
    const float scale = 0.6f + float(character.data.y) * 0.01f;
    const float3x3 rotationMatrixY = scale * characterModelScale * float3x3(
        cos(matrixAngle), 0.0f, -sin(matrixAngle),
        0.0f, 1.0f, 0.0f,
        sin(matrixAngle), 0.0f, cos(matrixAngle)
    );
    visibleCharacter.transform[0] = float4(rotationMatrixY[0], 0.0f);
    visibleCharacter.transform[1] = float4(rotationMatrixY[1], 0.0f);
    visibleCharacter.transform[2] = float4(rotationMatrixY[2], 0.0f);
    visibleCharacter.transform[3].xyz = character.position.xyz;
    if (index >= frame.characterData.z) {
        visibleCharacter.transform[3].y = -10000.0f;
    }
    
    // synchronize the motion controllers
    for (int motionIndex = 0; motionIndex < 25; motionIndex += 1) {
        const float4x2 motionController = character.motionControllers[motionIndex];
        visibleCharacter.motionControllers[motionIndex] = motionController;
    }
    
    // store the visible character
    visibleCharacters[index] = visibleCharacter;
}
