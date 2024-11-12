
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
    characters[index].position = float4(float(index % 10), 0.0f, float(index / 10), 1.0f);
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
    
    const float4 characterPosition = characters[index].position;
    const uint maxNumCharactersPerGrid = uint(frame.gridData.z);
    const uint width = uint(frame.gridData.w);
    
    const uint2 gridOffset = uint2(width) / uint2(gridDimX, gridDimZ);
    const uint gridIndexX = uint(characterPosition.x) % gridOffset.x;
    const uint gridIndexZ = uint(characterPosition.z) % gridOffset.y;
    const uint gridIndex = gridIndexX + gridIndexZ * gridDimX;
    const uint prevIndex = atomic_fetch_add_explicit(&characterCountPerGrid[gridIndex], 1, memory_order_relaxed);
    if (prevIndex < maxNumCharactersPerGrid) {
        characterIndexBuffer[gridIndex * maxNumCharactersPerGrid + prevIndex] = index;
    }
}
