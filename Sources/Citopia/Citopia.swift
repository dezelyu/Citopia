
// import the Metal graphics API
import MetalKit

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    var data: simd_float4 = .zero
    
    // define the character data
    //  - characterData.x = characterCount
    //  - characterData.y = visibleCharacterCount
    var characterData: simd_uint4 = .zero
    
    // define the position of the observer
    var observerPosition: simd_float4 = .zero
}

// define the character data
struct CharacterData {
    
    // define the position of the character
    var position: simd_float4 = .zero
}

// define the class for performing the simulation
class Citopia {
    
    // define the total number of characters to simulate
    var characterCount: Int = 0
    
    // define the total number of visible characters
    var visibleCharacterCount: Int = 0
    
    // define the graphics device
    var device: MTLDevice!
    
    // define the uniform buffer for the frame data
    var frameBuffer: MTLBuffer!
    
    // define the storage buffer for the character data
    var characterBuffer: MTLBuffer!
    
    // define the storage buffer for the indices of the visible characters
    var visibleCharacterIndexBuffer: MTLBuffer!
    
    // define the position of the observer
    var observerPosition: simd_float3 = .zero
    
    // define the constructor
    init(device: MTLDevice) {
        
        // store the graphics device
        self.device = device
        
        // create the frame buffer
        self.createFrameBuffer()
    }
    
    // define the character creator
    func createCharacters(characterCount: Int, visibleCharacterCount: Int) {
        
        // store the total number of characters to simulate
        self.characterCount = characterCount
        
        // store the total number of visible characters
        self.visibleCharacterCount = visibleCharacterCount
        
        // create the character buffer
        self.createCharacterBuffer()
        
        // create the visible character index buffer
        self.createVisibleCharacterIndexBuffer()
    }
    
    // define the simulation behavior
    func simulate(time: Float, commandBuffer: MTLCommandBuffer) {
        
        // update the frame buffer
        self.updateFrameBuffer(time: time)
    }
}
