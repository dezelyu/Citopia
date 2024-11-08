
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

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
};

// define the character data
struct CharacterData {
    
    // define the position of the character
    float4 position;
};

// define the naive simulation function
kernel void NaiveSimulationFunction(constant FrameData& frame [[buffer(0)]],
                                    device CharacterData* characters [[buffer(1)]],
                                    const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= frame.characterData.x) {
        return;
    }
    
    // update the character position
    characters[index].position = float4(float(index), 0.0f, 0.0f, 1.0f);
}
