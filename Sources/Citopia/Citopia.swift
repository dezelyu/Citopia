
// import the Metal graphics API
import MetalKit

// define the frame data
struct FrameData {
    
    // define the general frame data
    //  - data.x = time
    //  - data.y = delta time scale factor
    //  - data.z = zombification
    var data: simd_float4 = .zero
    
    // define the grid count data
    //  - gridCountData.x = gridCount
    var gridCountData: simd_uint4 = .zero
    
    // define the grid length data
    //  - gridLengthData.x = gridLength
    var gridLengthData: simd_float4 = .zero
    
    // define the block count data
    //  - blockCountData.x = block count
    var blockCountData: simd_uint4 = .zero
    
    // define the block length data
    //  - blockLengthData.x = block side length
    //  - blockLengthData.y = block distance
    var blockLengthData: simd_float4 = .zero
    
    // define the character data
    //  - characterData.x = character count
    //  - characterData.y = visible character count
    //  - characterData.z = actual visible character count
    var characterData: simd_uint4 = .zero
    
    // define the position of the observer
    var observerPosition: simd_float4 = .zero
    
    // define the frustrum data
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
    //  - data.z = occupation (0: office, 1: service)
    var data: simd_uint4 = .zero
    
    // define the personalities of the character
    var personalities: simd_float4 = .zero
    
    // define the states of the character
    //  - states.x = goal
    //      - 0 = wandering on the street
    //      - 1 = sleeping (determined by energy)
    //      - 2 = working (determined by gold)
    //      - 3 = socializing (determined by socialization impulse)
    //      - 4 = entertaining
    //      - 5 = idling
    //      - 100 = zombification
    //      - 101 = zombie wandering
    //      - 102 = zombie attack
    //      - 1000 = dead
    //  - states.y = goal planner state
    //  - states.z = target character
    //  - states.w = enemy character
    var states: simd_uint4 = .zero
    
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
    //  - stats[11] = idle termination time
    var stats: (
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float
    ) = (
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 0.0
    )
    
    // define the unique addresses of the character
    //  - addresses[0] = the current address
    //  - addresses[1] = the bed in the apartment
    //  - addresses[2] = the office in the office building
    //  - addresses[3] = the entertainment address
    var addresses: (
        simd_int4, simd_int4,
        simd_int4, simd_int4
    ) = (
        simd_int4(repeating: -1),
        simd_int4(repeating: -1),
        simd_int4(repeating: -1),
        simd_int4(repeating: -1)
    )
    
    // define the navigation data of the character
    //  - navigation.x = the ultimate destination map node index
    //  - navigation.y = the desired map node type
    //  - navigation.z = the temporary destination map node index
    //  - navigation.w = the previous map node index
    var navigation: simd_int4 = .zero
    
    // define the navigation target of the character
    //  - target.x = the target building index
    //  - target.y = the target map node index
    var target: simd_int4 = .zero
    
    // define the current map node data
    var mapNodeData: simd_int4 = .zero
    
    // define the velocity of the character
    var velocity: simd_float4 = .zero
    
    // define the position of the character
    var position: simd_float4 = .zero
    
    // define the destination of the character
    var destination: simd_float4 = .zero
    
    // define the movement data of the character
    //  - movement.x = current speed
    //  - movement.y = target speed
    //  - movement.z = current rotation
    //  - movement.w = target rotation
    var movement: simd_float4 = .zero
    
    // define the motion controllers
    var motionController: (
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2,
        simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2, simd_float4x2
    ) = (
        simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0),
        simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0), simd_float4x2(0.0)
    )
}

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
    //      - 6 = interactable node
    //  - data.y = orientation
    //  - data.w = connection count
    var data: simd_int4 = .zero
    
    // define the position of the map node
    var position: simd_float4 = .zero
    
    // define the dimension of the map node
    var dimension: simd_float4 = .zero
    
    // define the connections of the map node
    var connections: simd_int16 = simd_int16(repeating: -1)
}

// define the building data
struct BuildingData {
    
    // define the general building data
    //  - data.x = type
    //      - 1 = apartment
    //      - 2 = office
    //      - 3 = gym
    //      - 4 = restaurant
    //      - 5 = library
    //  - data.z = capacity
    //  - data.w = entrance count
    var data: simd_int4 = .zero
    
    // define the position of the building
    var position: simd_float4 = .zero
    
    // define the external entrances of the building
    var externalEntrances: simd_int4 = simd_int4(repeating: -1)
    
    // define the internal entrances of the building
    var internalEntrances: simd_int4 = simd_int4(repeating: -1)
    
    // define the interactable nodes
    var interactableNodes: simd_int16 = simd_int16(repeating: -1)
    
    // define the interactable node availabilities
    var interactableNodeAvailabilities: simd_int16 = simd_int16(repeating: 1)
}

// define the grid data
struct GridData {
    
    // define the index of start and end character index
    //  - data.x = start index
    //  - data.y = end index
    var data: simd_uint4 = .zero
}

// define the class for performing the simulation
class Citopia {
    
    // define the total number of characters to simulate
    var characterCount: Int = 0
    
    // define the total number of visible characters
    var visibleCharacterCount: Int = 0
    
    // define the actual number of visible characters
    var actualVisibleCharacterCount: Int = 0
    
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
    
    // define the character indirect buffer
    var characterIndirectBuffer: MTLBuffer!
    
    // define the character count buffer
    var characterCountBuffer: MTLBuffer!
    
    // define the physics simulation character index buffer
    var physicsSimulationCharacterIndexBuffer: MTLBuffer!
    
    // define the navigation character index buffer
    var navigationCharacterIndexBuffer: MTLBuffer!
    
    // define the socialization character index buffer
    var socializationCharacterIndexBuffer: MTLBuffer!
    
    // define the entertainment entrance character index buffer
    var entertainmentEntranceCharacterIndexBuffer: MTLBuffer!
    
    // define the entertainment exit character index buffer
    var entertainmentExitCharacterIndexBuffer: MTLBuffer!
    
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
    
    // define the storage buffer for the character index buffer per grid
    var characterIndexBufferPerGrid: MTLBuffer!
    
    // define the storage buffer for the grid data structure
    var gridDataBuffer: MTLBuffer!
    
    // define the atomic int for tracking next available grid index
    var nextAvailableGridBuffer: MTLBuffer!
    
    // define the atomic int for counting visible characters
    var visibleCharacterCountBuffer: MTLBuffer!
    
    // define the simulation pipeline
    var simulationPipeline: MTLComputePipelineState!
    
    // define the observation pipeline
    var observationPipeline: MTLComputePipelineState!
    
    // define the initialize indirect buffer pipeline
    var initializeIndirectBufferPipeline: MTLComputePipelineState!
    
    // define the physics simulation pipeline
    var physicsSimulationPipeline: MTLComputePipelineState!
    
    // define the navigation pipeline
    var navigationPipeline: MTLComputePipelineState!
    
    // define the socialization pipeline
    var socializationPipeline: MTLComputePipelineState!
    
    // define the entertainment entrance pipeline
    var entertainmentEntrancePipeline: MTLComputePipelineState!
    
    // define the entertainment exit pipeline
    var entertainmentExitPipeline: MTLComputePipelineState!
    
    // define the compute grid pipeline
    var computeGridPipeline: MTLComputePipelineState!
    
    // define the initialize grid pipeline
    var initializeGridPipeline: MTLComputePipelineState!
    
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
    
    // define the number of grids per row of the map
    var gridCount: Int = 0
    
    // define the side length of the grid in meters
    var gridLength: Float = 0
    
    // define the exterior connection data
    var exteriorConnectionData: Set<simd_int4> = []
    
    // define the building blocks to render
    var buildingBlocks: [(simd_float2, Float, simd_float3, Int, Bool)] = []
    
    // define the furniture blocks to render
    var furnitureBlocks: [(simd_float2, Float, simd_float3, Int)] = []
    
    // define the dictionary for all the bed data
    var bedData: [Int : Set<simd_int4>] = [:]
    
    // define the dictionary for all the office data
    var officeData: [Int : Set<simd_int4>] = [:]
    
    // define the dictionary for all the service industry worker
    var serviceIndustryWorkersData: [(simd_int4, simd_int4)] = []
    
    // define an array of all the map nodes
    var mapNodes: [MapNodeData] = []
    
    // define an array of all the buildings
    var buildings: [BuildingData] = []
    
    // define the storage buffer for the map node data
    var mapNodeBuffer: MTLBuffer!
    
    // define the storage buffer for the building data
    var buildingBuffer: MTLBuffer!
    
    // define the storage buffer for the character count per building data
    var characterCountPerBuildingBuffer: MTLBuffer!
    
    // define the variable that indicates whether to turn the characters near the observer into zombies
    var zombification: Bool = false
    
    // define the character group index
    var characterGroupIndex: Int = 0
    
    // define the constructor
    init(device: MTLDevice,
         characterCount: Int, visibleCharacterCount: Int,
         blockCount: Int, blockSideLength: Float, blockDistance: Float) {
        
        // save the arguments
        self.characterCount = characterCount
        self.visibleCharacterCount = visibleCharacterCount
        self.blockCount = blockCount
        self.blockSideLength = blockSideLength
        self.blockDistance = blockDistance
        self.gridCount = Int(ceil(Float(blockCount + 2) * 8.0))
        self.gridLength = (self.blockSideLength + self.blockDistance) * 0.125
        
        // store the graphics device
        self.device = device
        
        // create a new library
        self.library = self.device.makeDefaultLibrary()
        
        // create the frame buffer
        self.createFrameBuffer()
        
        // create the simulation pipeline
        self.createSimulationPipeline()
        
        // create the observation pipeline
        self.createObservationPipeline()
        
        // create the initialize indirect buffer pipeline
        self.createInitializeIndirectBufferPipeline()
        
        // create the physics simulation pipeline
        self.createPhysicsSimulationPipeline()
        
        // create the navigation pipeline
        self.createNavigationPipeline()
        
        // create the socialization pipeline
        self.createSocializationPipeline()
        
        // create the entertainment entrance pipeline
        self.createEntertainmentEntrancePipeline()
        
        // create the entertainment exit pipeline
        self.createEntertainmentExitPipeline()
        
        // create the compute grid pipeline
        self.createComputeGridPipeline()
        
        // create the initialize grid pipeline
        self.createInitializeGridPipeline()
        
        // create the set character index per grid pipeline
        self.createSetCharacterIndexPerGridPipeline()
        
        // create the find visible character pipeline
        self.createFindVisibleCharacterPipeline()
        
        // create the visible character simulation pipeline
        self.createVisibleCharacterSimulationPipeline()
    }
    
    // define the character creator
    func createCharacters(visibleCharacterBuffer: MTLBuffer) {
                
        // create the character buffer
        self.createCharacterBuffer()
        
        // create the visible character index buffer
        self.createVisibleCharacterIndexBuffer()
        
        // store the visible character buffer
        self.visibleCharacterBuffer = visibleCharacterBuffer
    }
    
    // define the grid data creator
    func createGrids() {
        
        // create the grid data buffers
        self.createGridDataBuffer()
        
        // create the character index buffer per grid
        self.createCharacterIndexBufferPerGrid()
    }
    
    // define the simulation behavior
    func simulate(time: Float, commandBuffer: MTLCommandBuffer) {
        
        // update the frame buffer
        self.updateFrameBuffer(time: time)
        
        // reset the buffers
        if let encoder = commandBuffer.makeBlitCommandEncoder() {
            encoder.fill(
                buffer: self.characterCountBuffer,
                range: 0..<self.characterCountBuffer.length,
                value: 0
            )
            encoder.fill(
                buffer: self.visibleCharacterCountBuffer,
                range: 0..<self.visibleCharacterCountBuffer.length,
                value: 0
            )
            encoder.fill(
                buffer: self.nextAvailableGridBuffer,
                range: 0..<self.nextAvailableGridBuffer.length,
                value: 0
            )
            encoder.fill(
                buffer: self.characterCountPerBuildingBuffer,
                range: 0..<self.characterCountPerBuildingBuffer.length,
                value: 0
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
            
            // configure the simulation pipeline
            encoder.setComputePipelineState(self.simulationPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.physicsSimulationCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.navigationCharacterIndexBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.socializationCharacterIndexBuffer, offset: 0, index: 5)
            encoder.setBuffer(self.entertainmentEntranceCharacterIndexBuffer, offset: 0, index: 6)
            encoder.setBuffer(self.entertainmentExitCharacterIndexBuffer, offset: 0, index: 7)
            
            // dispatch threadgroups for the simulation pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.simulationPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.simulationPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // configure the observation pipeline
            encoder.setComputePipelineState(self.observationPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.gridDataBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 3)
            
            // dispatch threadgroups for the observation pipeline
            let workload = Int(self.characterCount / 30)
            encoder.dispatchThreadgroups(
                MTLSizeMake(workload / (self.simulationPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.simulationPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // configure the initialize indirect buffer pipeline
            encoder.setComputePipelineState(self.initializeIndirectBufferPipeline)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterIndirectBuffer, offset: 0, index: 1)
            
            // dispatch threadgroups for the initialize indirect buffer pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(10 / self.simulationPipeline.threadExecutionWidth + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.simulationPipeline.threadExecutionWidth, 1, 1)
            )
            
            // configure the physics simulation pipeline
            encoder.setComputePipelineState(self.physicsSimulationPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.physicsSimulationCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.gridDataBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 5)
            
            // dispatch threadgroups for the physics simulation pipeline
            encoder.dispatchThreadgroups(
                indirectBuffer: self.characterIndirectBuffer,
                indirectBufferOffset: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 0,
                threadsPerThreadgroup: MTLSizeMake(64, 1, 1)
            )
            
            // configure the navigation pipeline
            encoder.setComputePipelineState(self.navigationPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.navigationCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.mapNodeBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.buildingBuffer, offset: 0, index: 5)
            
            // dispatch threadgroups for the navigation pipeline
            encoder.dispatchThreadgroups(
                indirectBuffer: self.characterIndirectBuffer,
                indirectBufferOffset: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 1,
                threadsPerThreadgroup: MTLSizeMake(64, 1, 1)
            )
            
            // configure the socialization pipeline
            encoder.setComputePipelineState(self.socializationPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.socializationCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.gridDataBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 5)
            
            // dispatch threadgroups for the physics simulation pipeline
            encoder.dispatchThreadgroups(
                indirectBuffer: self.characterIndirectBuffer,
                indirectBufferOffset: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 2,
                threadsPerThreadgroup: MTLSizeMake(64, 1, 1)
            )
            
            // configure the entertainment entrance pipeline
            encoder.setComputePipelineState(self.entertainmentEntrancePipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.entertainmentEntranceCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.buildingBuffer, offset: 0, index: 4)
            encoder.setBuffer(self.characterCountPerBuildingBuffer, offset: 0, index: 5)
            
            // dispatch threadgroups for the entertainment entrance pipeline
            encoder.dispatchThreadgroups(
                indirectBuffer: self.characterIndirectBuffer,
                indirectBufferOffset: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 2,
                threadsPerThreadgroup: MTLSizeMake(64, 1, 1)
            )
            
            // configure the entertainment exit pipeline
            encoder.setComputePipelineState(self.entertainmentExitPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountBuffer, offset: 0, index: 2)
            encoder.setBuffer(self.entertainmentExitCharacterIndexBuffer, offset: 0, index: 3)
            encoder.setBuffer(self.buildingBuffer, offset: 0, index: 4)
            
            // dispatch threadgroups for the entertainment exit pipeline
            encoder.dispatchThreadgroups(
                indirectBuffer: self.characterIndirectBuffer,
                indirectBufferOffset: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 2,
                threadsPerThreadgroup: MTLSizeMake(64, 1, 1)
            )
            
            // finish encoding
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        // reset the buffers
        if let encoder = commandBuffer.makeBlitCommandEncoder() {
            encoder.fill(
                buffer: self.characterCountPerGridBuffer,
                range: 0..<self.characterCountPerGridBuffer.length,
                value: 0
            )
            encoder.fill(
                buffer: self.gridDataBuffer,
                range: 0..<self.gridDataBuffer.length,
                value: 0
            )
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        // create a new compute command encoder
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            
            // configure the compute grid pipeline
            encoder.setComputePipelineState(self.computeGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 2)
            
            // dispatch threadgroups for the compute grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.computeGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.computeGridPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // configure the initialize grid piepline
            encoder.setComputePipelineState(self.initializeGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 1)
            encoder.setBuffer(self.gridDataBuffer,  offset: 0, index: 2)
            encoder.setBuffer(self.nextAvailableGridBuffer,  offset: 0, index: 3)
            
            // dispatch threadgroups for the initialize grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.gridCount * self.gridCount / (self.initializeGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.initializeGridPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // finish encoding
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        // reset the buffers
        if let encoder = commandBuffer.makeBlitCommandEncoder() {
            encoder.fill(
                buffer: self.characterCountPerGridBuffer,
                range: 0..<self.characterCountPerGridBuffer.length,
                value: 0
            )
            encoder.endEncoding()
        } else {
            fatalError()
        }
        
        // create a new compute command encoder
        if let encoder = commandBuffer.makeComputeCommandEncoder() {
            
            // configure the set character index per grid
            encoder.setComputePipelineState(self.setCharacterIndexPerGridPipeline)
            encoder.setBuffer(self.frameBuffer, offset: 0, index: 0)
            encoder.setBuffer(self.characterBuffer, offset: 0, index: 1)
            encoder.setBuffer(self.characterCountPerGridBuffer,  offset: 0, index: 2)
            encoder.setBuffer(self.characterIndexBufferPerGrid, offset: 0, index: 3)
            encoder.setBuffer(self.gridDataBuffer,  offset: 0, index: 4)
            
            // dispatch threadgroups for the set character index per grid pipeline
            encoder.dispatchThreadgroups(
                MTLSizeMake(self.characterCount / (self.setCharacterIndexPerGridPipeline.threadExecutionWidth * 2) + 1, 1, 1),
                threadsPerThreadgroup: MTLSizeMake(self.setCharacterIndexPerGridPipeline.threadExecutionWidth * 2, 1, 1)
            )
            
            // dispatch threadgroups for the find visible character pipeline
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
