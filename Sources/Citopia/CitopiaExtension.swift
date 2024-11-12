
// import the Metal graphics API
import MetalKit

// define the class extension for all the utility functions
extension Citopia {
    
    // define the function that creates the frame buffer
    func createFrameBuffer() {
        
        // create a host-writable buffer
        self.frameBuffer = self.device.makeBuffer(
            length: MemoryLayout<FrameData>.stride,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // update the label of the frame buffer
        self.frameBuffer.label = "FrameBuffer"
    }
    
    // define the function that creates the naive simulation pipeline
    func createNaiveSimulationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "NaiveSimulationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.naiveSimulationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the compute grid pipeline
    func createComputeGridPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "ComputeGridFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.computeGridPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the character buffer
    func createCharacterBuffer() {
        
        // create a private storage buffer
        self.characterBuffer = self.device.makeBuffer(
            length: MemoryLayout<CharacterData>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character buffer
        self.characterBuffer.label = "CharacterBuffer"
    }
    
    // define the function that creates the visible character index buffer
    func createVisibleCharacterIndexBuffer() {
        
        // create a private storage buffer
        self.visibleCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.visibleCharacterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.visibleCharacterIndexBuffer.label = "VisibleCharacterIndexBuffer"
    }
    
    // define the function that updates the frame buffer
    func updateFrameBuffer(time: Float) {
        
        // acquire a pointer to the frame buffer
        let pointer = self.frameBuffer.contents().bindMemory(
            to: FrameData.self, capacity: 1
        )
        
        // update the time
        pointer.pointee.data.x = time
        
        // update the character data
        pointer.pointee.characterData = simd_uint4(
            UInt32(self.characterCount),
            UInt32(self.visibleCharacterCount),
            0, 0
        )
        
        // update the position of the observer
        pointer.pointee.observerPosition = simd_float4(
            self.observerPosition, 1.0
        )
        
        pointer.pointee.gridData = simd_float4(
            Float32(self.gridDimensionX),
            Float32(self.gridDimensionZ),
            Float32(self.maxNumCharactersPerGrid),
            100.0
        )
    }
    
    // define the function that creates the grid data buffer
    func createGridDataBuffer() {
        
        // create a private storage buffer
        self.characterCountPerGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.gridDimensionX * self.gridDimensionZ,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.characterCountPerGridBuffer.label = "CharacterCountPerGridBuffer"
        
        // create a private storage buffer
        self.initialCharacterCountPerGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.gridDimensionX * self.gridDimensionZ,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.initialCharacterCountPerGridBuffer.label = "InitialCharacterCountPerGridBuffer"
    }
    
    // define the function that creates the character index buffer per grid
    func createCharacterIndexBufferPerGrid() {
        
        // create a private storage buffer
        self.characterIndexBufferPerGrid = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.gridDimensionX * self.gridDimensionZ * self.maxNumCharactersPerGrid,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.characterIndexBufferPerGrid.label = "CharacterIndexBufferPerGrid"
    }
}
