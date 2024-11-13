
// import the Metal graphics API
import MetalKit

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    //  - data.z = maxVisibleDistance
    var data: simd_float4 = .zero
    
    // define the character data
    //  - characterData.x = characterCount
    //  - characterData.y = visibleCharacterCount
    //  - characterData.z = actualVisibleCharacterCount
    var characterData: simd_uint4 = .zero
    
    // define the position of the observer
    var observerPosition: simd_float4 = .zero
    
    // define the grid data
    //  - gridData.x = gridDimX
    //  - gridData.y = gridDimZ
    //  - gridData.z = maxNumCharactersPerGrid
    //  - gridData.w = width/height
    var gridData: simd_float4 = .zero
}

// define the character data
struct CharacterData {
    
    // characterInformation.x is gender
    // characterInformation.z is current time threshold
    // characterInformation.w is the accumulated time threshold
    var characterInformation: simd_float4 = .zero
    
    // define the position of the character
    // .xyz position of the character
    var position: simd_float4 = .zero
    
    // motionInformation.x is the current speed
    // motionInformation.y is the target speed
    // motionInformation.z is the current anticlockwise angle in radians
    // motionInformation.w is the target anticlockwise rotation angle in radians
    var motionInformation: simd_float4 = .zero
}

// define the class for performing the simulation
class Citopia {
    
    // define the total number of characters to simulate
    var characterCount: Int = 0
    
    // define the total number of visible characters
    var visibleCharacterCount: Int = 0
    
    // define the actual number of visible characters within maxVisibleDistance
    var actualVisibleCharacterCount: Int = 0
    
    // define the grid dimension X
    var gridDimensionX: Int = 10
    
    // define the grid dimension Z
    var gridDimensionZ: Int = 10
    
    // define the max number of characters per grid
    var maxNumCharactersPerGrid: Int = 100
    
    // define the max visible distance
    var maxVisibleDistance: Float = 100.0
    
    // define the previous time
    var previousTime: Float = .zero
    
    // define the graphics device
    var device: MTLDevice!
    
    // define the shader library
    var library: MTLLibrary!
    
    // define the uniform buffer for the frame data
    var frameBuffer: MTLBuffer!
    
    // define the storage buffer for the character data
    var characterBuffer: MTLBuffer!
    
    // define the storage buffer for the indices of the potentially visible characters
    var potentiallyVisibleCharacterIndexBuffer: MTLBuffer!
    
    // define the storage buffer for the visible character's distance to observer buffer
    var visibleCharacterDistanceToObserverBuffer: MTLBuffer!
    
    // define the storage buffer for the indices of the visible characters
    var visibleCharacterIndexBuffer: MTLBuffer!
    
    // define the buffer for the visible characters
    var visibleCharacterBuffer: MTLBuffer!
    
    // define the storage buffer for the character count per grid data
    var characterCountPerGridBuffer: MTLBuffer!
    
    // define the storage buffer for the initial character count per grid data
    var initialCharacterCountPerGridBuffer: MTLBuffer!
    
    // define the storage buffer for the character index buffer per grid
    var characterIndexBufferPerGrid: MTLBuffer!
    
    // define the initial atomic int for counting visible characters
    var initialVisibleCharacterCountBuffer: MTLBuffer!
    
    // define the atomic int for counting visible characters
    var visibleCharacterCountBuffer: MTLBuffer!
    
    // define the naive simulation pipeline
    var naiveSimulationPipeline: MTLComputePipelineState!
    
    // define the compute grid pipeline
    var computeGridPipeline: MTLComputePipelineState!
    
    // define the find visible character pipeline
    var findVisibleCharacterPipeline: MTLComputePipelineState!
    
    // define the simulate visible character pipeline
    var simulateVisibleCharacterPipeline: MTLComputePipelineState!
    
    // define the position of the observer
    var observerPosition: simd_float3 = .zero
    
    // define the frustum planes
    var frustumPlanes: [simd_float4] = []
    
    // define the constructor
    init(device: MTLDevice) {
        
        // store the graphics device
        self.device = device
        
        // create a new library
        self.library = self.device.makeDefaultLibrary()
        
        // create the frame buffer
        self.createFrameBuffer()
        
        // create the naive simulation pipeline
        self.createNaiveSimulationPipeline()
        
        // create the compute grid pipeline
        self.createComputeGridPipeline()
        
        // create the find visible character pipeline
        self.createFindVisibleCharacterPipeline()
        
        // create the visible character simulation pipeline
        self.createVisibleCharacterSimulationPipeline()
    }
    
    // define the character creator
    func createCharacters(characterCount: Int, visibleCharacterCount: Int, visibleCharacterBuffer: MTLBuffer) {
        
        // store the total number of characters to simulate
        self.characterCount = characterCount
        
        // store the total number of visible characters
        self.visibleCharacterCount = visibleCharacterCount
        
        // create the character buffer
        self.createCharacterBuffer()
        
        // create the visible character index buffer
        self.createVisibleCharacterIndexBuffer()
        
        // store the visible character buffer
        self.visibleCharacterBuffer = visibleCharacterBuffer
    }
    
    // define the grid data creator
    func createGrids(){
        
        //create the grid data buffers
        self.createGridDataBuffer()
        
        //create the character index buffer per grid
        self.createCharacterIndexBufferPerGrid()
    }
    
    // define the simulation behavior
    func simulate(time: Float, commandBuffer: MTLCommandBuffer) {
        
        // update the frame buffer
        self.updateFrameBuffer(time: time)
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(
            from: self.initialCharacterCountPerGridBuffer, sourceOffset: 0,
            to: self.characterCountPerGridBuffer, destinationOffset: 0,
            size: self.characterCountPerGridBuffer.length
        )
        blitEncoder.copy(
            from: self.initialVisibleCharacterCountBuffer, sourceOffset: 0,
            to: self.visibleCharacterCountBuffer, destinationOffset: 0,
            size: MemoryLayout<UInt32>.stride
        )
        blitEncoder.endEncoding()
        
        // create a new compute command encoder
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        
        // configure the simulate visible character pipeline
        encoder.setComputePipelineState(self.simulateVisibleCharacterPipeline)
        encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
        encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
        encoder.setBuffer(self.visibleCharacterBuffer, offset: 0, index: 2)
        encoder.setBuffer(self.visibleCharacterIndexBuffer, offset: 0, index: 3)
        
        // perform the simulate visible character pipeline
        encoder.dispatchThreadgroups(
            MTLSizeMake(self.visibleCharacterCount / (self.simulateVisibleCharacterPipeline.threadExecutionWidth * 2) + 1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(self.simulateVisibleCharacterPipeline.threadExecutionWidth * 2, 1, 1)
        )
        
        // configure the naive simulation pipeline
        encoder.setComputePipelineState(self.naiveSimulationPipeline)
        encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
        encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
        encoder.setBuffer(self.visibleCharacterBuffer, offset: 0, index: 2)
        
        // perform the naive simulation
        encoder.dispatchThreadgroups(
            MTLSizeMake(self.characterCount / (self.naiveSimulationPipeline.threadExecutionWidth * 2) + 1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(self.naiveSimulationPipeline.threadExecutionWidth * 2, 1, 1)
        )
        
        // configure the compute grid pipeline
        encoder.setComputePipelineState(self.computeGridPipeline)
        encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
        encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
        encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 2)
        encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 3)
        
        // perform the compute grid pipeline
        encoder.dispatchThreadgroups(
            MTLSizeMake(self.characterCount / (self.computeGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(self.computeGridPipeline.threadExecutionWidth * 2, 1, 1)
        )
        
        // configure the find visible character pipeline
        encoder.setComputePipelineState(self.findVisibleCharacterPipeline)
        encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
        encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
        encoder.setBuffer(self.visibleCharacterCountBuffer,  offset: 0, index: 2)
        encoder.setBuffer(self.potentiallyVisibleCharacterIndexBuffer, offset: 0, index: 3)
        encoder.setBuffer(self.visibleCharacterDistanceToObserverBuffer, offset: 0, index: 4)
        
        // perform the find visible character pipeline
        encoder.dispatchThreadgroups(
            MTLSizeMake(self.characterCount / (self.findVisibleCharacterPipeline.threadExecutionWidth * 2) + 1, 1, 1),
            threadsPerThreadgroup: MTLSizeMake(self.findVisibleCharacterPipeline.threadExecutionWidth * 2, 1, 1)
        )
        
        // finish encoding
        encoder.endEncoding()
    }
}
