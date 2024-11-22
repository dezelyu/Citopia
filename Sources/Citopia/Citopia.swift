
// import the Metal graphics API
import MetalKit

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    //  - data.z = maxVisibleDistance
    var data: simd_float4 = .zero
    
    // define the map data
    //  - mapData.x = blockCount
    var mapData: simd_uint4 = .zero
    
    // define the character data
    //  - characterData.x = characterCount
    //  - characterData.y = visibleCharacterCount
    //  - characterData.z = actualVisibleCharacterCount
    var characterData: simd_uint4 = .zero
    
    // define the position of the observer
    var observerPosition: simd_float4 = .zero
    
    // define the grid data
    //  - gridData.x = mapGridCount
    //  - gridData.y = linkedGridCount
    //  - gridData.z = maxNumCharactersPerGrid
    var gridData: simd_uint4 = .zero
    
    // define the grid dimension data
    //  - gridLengthData.x = gridLengthX
    //  - gridLengthData.y = gridLengthZ
    var gridLengthData: simd_float4 = .zero
    
    var frustumData: (
        simd_float4, simd_float4,
        simd_float4, simd_float4,
        simd_float4, simd_float4
    ) = (
        simd_float4(repeating: 0.0), simd_float4(repeating: 0.0),
        simd_float4(repeating: 0.0), simd_float4(repeating: 0.0),
        simd_float4(repeating: 0.0), simd_float4(repeating: 0.0)
    )
}

// define the character data
struct CharacterData {
    
    // define the integer data of the character
    //  - data.x = gender (0: female, 1: male)
    //  - data.y = age (20 - 40)
    //  - data.z = color
    //  - data.w = destination
    var data: simd_uint4 = .zero
    
    // define the position of the character
    var position: simd_float4 = .zero
    
    // define the destination of the character
    var destination: simd_float4 = .zero
    
    // define the motion information of the character
    //   - motionInformation.x = current speed
    //   - motionInformation.y = target speed
    //   - motionInformation.z = current anticlockwise angle in radians
    //   - motionInformation.w = target anticlockwise rotation angle in radians
    var motionInformation: simd_float4 = .zero
    
    // define the motion controllers
    var motionController: (
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2
    ) = (
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0)
    )
}

// define the map node data
struct MapNodeData {
    
    // define the general map node data
    //  - data.x = type
    //  - data.w = connection count
    var data: simd_int4 = .zero
    
    // define the position of the map node
    var position: simd_float4 = .zero
    
    // define the dimension of the map node
    var dimension: simd_float4 = .zero
    
    // define the connections of the map node
    var connections: simd_int16 = simd_int16(repeating: -1)
}

struct GridData {
    
    // define the index of the next grid, used to store additional characters
    //  - next.x = next grid index
    var next: simd_int4 = .zero
}

// define the class for performing the simulation
class Citopia {
    
    // define the total number of characters to simulate
    var characterCount: Int = 0
    
    // define the total number of visible characters
    var visibleCharacterCount: Int = 0
    
    // define the actual number of visible characters within maxVisibleDistance
    var actualVisibleCharacterCount: Int = 0
    
    // define the map grid count
    var mapGridCount: Int = 0
    
    // define the grid count for storing additional characters
    var linkedGridCount: Int = 0
    
    // define the grid dimension in x
    var gridLengthX: Float = 0
    
    // define the grid dimension in z
    var gridLengthZ: Float = 0
    
    // define the max number of characters per grid
    var maxNumCharactersPerGrid: Int = 0
    
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
    
    // define the storage buffer for the character count per linked grid data
    var characterCountPerLinkedGridBuffer: MTLBuffer!
    
    // define the storage buffer for the initial character count per grid data
    var initialCharacterCountPerGridBuffer: MTLBuffer!
    
    // define the storage buffer for the character index buffer per grid
    var characterIndexBufferPerGrid: MTLBuffer!
    
    // define the storage buffer for the initial grid data structure
    var initialGridDataBuffer: MTLBuffer!
    
    // define the storage buffer for the grid data structure
    var gridDataBuffer: MTLBuffer!
    
    // define the initial atomic int for tracking next available grid index
    var initialNextAvailableGridBuffer: MTLBuffer!
    
    // define the atomic int for tracking next available grid index
    var nextAvailableGridBuffer: MTLBuffer!
    
    // define the initial atomic int for counting visible characters
    var initialVisibleCharacterCountBuffer: MTLBuffer!
    
    // define the atomic int for counting visible characters
    var visibleCharacterCountBuffer: MTLBuffer!
    
    // define the naive simulation pipeline
    var naiveSimulationPipeline: MTLComputePipelineState!
    
    // define the compute grid pipeline
    var computeGridPipeline: MTLComputePipelineState!
    
    // define the assign linked grid pipeline
    var assignLinkedGridPipeline: MTLComputePipelineState!
    
    // define the set character index per grid pipeline
    var setCharacterIndexPerGridPipeline: MTLComputePipelineState!
    
    // define the find visible character pipeline
    var findVisibleCharacterPipeline: MTLComputePipelineState!
    
    // define the simulate visible character pipeline
    var simulateVisibleCharacterPipeline: MTLComputePipelineState!
    
    // define the position of the observer
    var observerPosition: simd_float3 = .zero
    
    // define the frustum planes
    var frustumPlanes: [simd_float4] = [simd_float4](repeating: .zero, count: 6)
    
    // define the number of blocks per row of the map
    var blockCount: Int = 0
    
    // define the side length of the block in meters
    var blockSideLength: Float = 0
    
    // define the distance between two blocks in meters
    var blockDistance: Float = 0
    
    // define the exterior connection data
    var exteriorConnectionData: Set<String> = []
    
    // define the foundational building blocks to render
    var foundationalBuildingBlocks: [(simd_float2, Float, simd_float3, Int)] = []
    
    // define an array of all the map nodes
    var mapNodes: [MapNodeData] = []
    
    // define the storage buffer for the map node data
    var mapNodeBuffer: MTLBuffer!
    
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
        
        // create the assign linked grid pipeline
        self.createAssignLinkedGridPipeline()
        
        // create the set character index per grid pipeline
        self.createSetCharacterIndexPerGridPipeline()
        
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
    func createGrids(maxNumCharactersPerGrid: Int) {
        
        // set the max number of characters per grid
        self.maxNumCharactersPerGrid = maxNumCharactersPerGrid
        
        // create the grid data buffers
        self.createGridDataBuffer()
        
        // create the character index buffer per grid
        self.createCharacterIndexBufferPerGrid()
    }
    
    // define the simulation behavior
    func simulate(time: Float, commandBuffer: MTLCommandBuffer) {
        
        // update the frame buffer
        self.updateFrameBuffer(time: time)
        
        if let encoder = commandBuffer.makeBlitCommandEncoder() {
            encoder.copy(
                from: self.initialVisibleCharacterCountBuffer, sourceOffset: 0,
                to: self.visibleCharacterCountBuffer, destinationOffset: 0,
                size: MemoryLayout<UInt32>.stride
            )
            encoder.copy(
                from: self.initialNextAvailableGridBuffer, sourceOffset: 0,
                to: self.nextAvailableGridBuffer, destinationOffset: 0,
                size: MemoryLayout<UInt32>.stride
            )
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        // create a new compute command encoder
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
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
            encoder.setBuffer(self.mapNodeBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.gridDataBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 5)
            encoder.setBuffer(self.characterCountPerLinkedGridBuffer, offset: 0, index: 6)
            
            // perform the naive simulation
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.naiveSimulationPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.naiveSimulationPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        if let encoder = commandBuffer.makeBlitCommandEncoder() {
            encoder.copy(
                from: self.initialCharacterCountPerGridBuffer, sourceOffset: 0,
                to: self.characterCountPerGridBuffer, destinationOffset: 0,
                size: self.characterCountPerGridBuffer.length
            )
            encoder.copy(
                from: self.initialCharacterCountPerGridBuffer, sourceOffset: 0,
                to: self.characterCountPerLinkedGridBuffer, destinationOffset: 0,
                size: self.characterCountPerLinkedGridBuffer.length
            )
            encoder.copy(
                from: self.initialGridDataBuffer, sourceOffset: 0,
                to: self.gridDataBuffer, destinationOffset: 0,
                size: self.gridDataBuffer.length
            )
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            
            // configure the compute grid pipeline
            encoder.setComputePipelineState(self.computeGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 2)
            
            // perform the compute grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.computeGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.computeGridPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // configure the assign linked grid piepline
            encoder.setComputePipelineState(self.assignLinkedGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 1)
            encoder.setBuffer(self.gridDataBuffer,  offset: 0, index: 2)
            encoder.setBuffer(self.nextAvailableGridBuffer,  offset: 0, index: 3)
            
            // perform the assign linked grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.mapGridCount / (self.assignLinkedGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.assignLinkedGridPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // configure the set character index per grid
            encoder.setComputePipelineState(self.setCharacterIndexPerGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountPerLinkedGridBuffer,  offset: 0, index: 2)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 3)
            encoder.setBuffer(self.gridDataBuffer,  offset: 0, index: 4)
            
            // perform the assign linked grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.setCharacterIndexPerGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.setCharacterIndexPerGridPipeline.threadExecutionWidth * 2, 1, 1)
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
        } else {
            fatalError()
        }
    }
}
