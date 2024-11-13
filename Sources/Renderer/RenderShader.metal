
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = sex
    //  - data.w = character node index
    uint4 data;
    
    // define the indices of the female mesh nodes
    uint4 femaleMeshNodeIndices;
    
    // define the indices of the male mesh nodes
    uint4 maleMeshNodeIndices;
    
    // define the transform of the visible character
    float4x4 transform;
    
    // define the motion controller indices
    int motionControllerIndices[100];
    
    // define the motion controllers
    float4 motionControllers[100];
};

// define the node data
struct NodeData {
    int4 node;
    float4x4 matrix;
};

// define the motion controller data
struct MotionControllerData {
    float4x2 controller;
};

// define the function that update the nodes based on the visible characters
kernel void UpdateFunction(device VisibleCharacterData* characters [[buffer(0)]],
                           device NodeData* nodes [[buffer(1)]],
                           device MotionControllerData* controllers [[buffer(2)]],
                           constant uint& workload [[buffer(3)]],
                           const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= workload) {
        return;
    }
    
    // acquire the current character
    VisibleCharacterData character = characters[index];
    
    // update the character mesh based on the character sex
    nodes[character.femaleMeshNodeIndices.x].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.y].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.z].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.w].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.x].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.y].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.z].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.w].node.w = character.data.x != 0 ? character.data.w : -1;
    
    // update the character node index
    nodes[character.data.w].matrix = character.transform;
    
    // update the motions
    for (int i = 0; i < 100; i += 1) {
        const int motionControllerIndex = character.motionControllerIndices[i];
        const float4 motionController = character.motionControllers[i];
        const float time = motionController.x;
        const float weight = motionController.y;
        const float2 attacks = float2(0.3f);
        if (time >= 0.0f) {
            float4x2 controller = controllers[motionControllerIndex].controller;
            float2 weights = controller[1];
            float2 duration = float2(time - motionController.z, time - motionController.w);
            if (controller[0][0] < 0.0f && duration[0] > abs(controller[0][0])) {
                controllers[motionControllerIndex].controller[1] = float2(0.0f);
                controllers[motionControllerIndex].controller[2] = float2(0.0f);
                duration = float2(time);
            }
            const float progress = controller[0][0] > 0.0f ? fmod(duration[0], abs(controller[0][0])) : min(duration[0], abs(controller[0][0]));
            if (duration[1] < attacks[0]) {
                const float factor = 0.5f - cos(duration[1] / attacks[0] * 3.1415926535f) * 0.5f;
                weights = float2(weights[0] * (1.0f - factor) + weights[1] * factor, weight);
            } else {
                weights = float2(weights[1], weight);
            }
            controller[1] = weights;
            controller[2] = attacks;
            character.motionControllers[i].z = time - (weights[0] == 0.0f ? 0.0f : progress);
            character.motionControllers[i].w = time;
            controllers[motionControllerIndex].controller = controller;
        }
    }
}
