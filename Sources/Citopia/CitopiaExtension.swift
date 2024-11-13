
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
    
    // define the function that creates the find visible character pipeline
    func createFindVisibleCharacterPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "FindVisibleCharactersFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.findVisibleCharacterPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the create visible character simulation pipeline
    func createVisibleCharacterSimulationPipeline(){
        // acquire the function from the library
        let function = self.library.makeFunction(name: "SimulateVisibleCharacterFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.simulateVisibleCharacterPipeline = try! self.device.makeComputePipelineState(
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
        
        // create a shared storage buffer
        self.potentiallyVisibleCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModeShared
            ]
        )!
        // update the label of the potentially visible character index buffer
        self.potentiallyVisibleCharacterIndexBuffer.label = "PotentiallyVisibleCharacterIndexBuffer"
        
        // create a shared storage buffer
        self.visibleCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.visibleCharacterCount,
            options: [
                .storageModeShared,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.visibleCharacterIndexBuffer.label = "VisibleCharacterIndexBuffer"
        
        // create a private storage buffer
        self.initialVisibleCharacterCountBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 1,
            options: [
                .storageModePrivate
            ]
        )!
        
        // update the label of the initial atomic int visible character count buffer
        self.initialVisibleCharacterCountBuffer.label = "InitialVisibleCharacterCount"
        
        // create a private storage buffer
        self.visibleCharacterCountBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 1,
            options: [
                .storageModeShared,
            ]
        )!
        
        // update the label of the initial atomic int visible character count buffer
        self.visibleCharacterCountBuffer.label = "VisibleCharacterCount"
        
        // create a shared storage buffer
        self.visibleCharacterDistanceToObserverBuffer = self.device.makeBuffer(
            length: MemoryLayout<Float32>.stride * characterCount,
            options: [
                .storageModeShared,
            ]
        )!
        
        // update the label of visible character distance to observer buffer
        self.visibleCharacterDistanceToObserverBuffer.label = "VisibleCharacterDistanceToObserver"
    }
    
    // define the function that updates the frame buffer
    func updateFrameBuffer(time: Float) {
        
        // acquire a pointer to the frame buffer
        let pointer = self.frameBuffer.contents().bindMemory(
            to: FrameData.self, capacity: 1
        )
        
        // update the time
        pointer.pointee.data.x = time
        
        // update the delta time scale factor
        pointer.pointee.data.y = (time - self.previousTime) / (1.0 / 60.0)
        self.previousTime = time
        
        // update the maxVisibleDistance
        pointer.pointee.data.z = self.maxVisibleDistance
        
        // update the character data
        pointer.pointee.characterData = simd_uint4(
            UInt32(self.characterCount),
            UInt32(self.visibleCharacterCount),
            UInt32(self.actualVisibleCharacterCount),
            0
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
        
        pointer.pointee.frustumData = (
            frustumPlanes[0],
            frustumPlanes[1],
            frustumPlanes[2],
            frustumPlanes[3],
            frustumPlanes[4],
            frustumPlanes[5]
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
    
    // define the sort character index process
    func sortVisibleCharacterIndexBufferByDistance() {
        
        var hostVisibleCharacterCount = [UInt32](repeating: 0, count: 1)
        memcpy(
            &hostVisibleCharacterCount,
            self.visibleCharacterCountBuffer.contents(),
            MemoryLayout<UInt32>.stride * 1
        )
        self.actualVisibleCharacterCount = Int(hostVisibleCharacterCount[0])
        
        // copy device characterDistanceToObserverBuffer to host
        var hostCharacterDistanceToObserverBuffer = [Float32](
            repeating: 0.0, count: self.actualVisibleCharacterCount
        )
        memcpy(
            &hostCharacterDistanceToObserverBuffer,
            self.visibleCharacterDistanceToObserverBuffer.contents(),
            MemoryLayout<Float32>.stride * self.actualVisibleCharacterCount
        )
        
        // copy device potentiallyVisibleCharacterIndexBuffer to host
        var hostCharacterIndexBufferUInt32 = [UInt32](
            repeating: 0, count: self.actualVisibleCharacterCount
        )
        memcpy(
            &hostCharacterIndexBufferUInt32,
            self.potentiallyVisibleCharacterIndexBuffer.contents(),
            MemoryLayout<UInt32>.stride * self.actualVisibleCharacterCount
        )
        
        // perform sorting
        let sortedIndices = zip(hostCharacterDistanceToObserverBuffer, hostCharacterIndexBufferUInt32).sorted {
            $0.0 < $1.0
        }
        
        hostCharacterIndexBufferUInt32 = sortedIndices.map { element in
            return UInt32(element.1)
        }
        
        self.actualVisibleCharacterCount = min(self.actualVisibleCharacterCount, self.visibleCharacterCount)
        
        // copy host visibleCharacterIndexBuffer to device
        memcpy(
            self.visibleCharacterIndexBuffer.contents(),
            hostCharacterIndexBufferUInt32,
            MemoryLayout<UInt32>.stride * self.actualVisibleCharacterCount
        )
    }
}
