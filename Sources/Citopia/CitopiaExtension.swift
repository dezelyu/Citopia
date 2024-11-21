
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
    
    // define the function that creates the assign linked grid pipeline
    func createAssignLinkedGridPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "AssignLinkedGridFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.assignLinkedGridPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the set character index per grid pipeline
    func createSetCharacterIndexPerGridPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "SetCharacterIndexPerGridFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.setCharacterIndexPerGridPipeline = try! self.device.makeComputePipelineState(
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
        
        // create a staging buffer with the map node data
        let stagingBuffer = self.device.makeBuffer(
            length: MemoryLayout<CharacterData>.stride * self.characterCount,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // acquire the pointer to the staging buffer
        let pointer = stagingBuffer.contents().bindMemory(
            to: CharacterData.self, capacity: self.characterCount
        )
        
        for index in 0...self.characterCount {
            
            // initialize gender
            pointer[index].data.x = UInt32.random(in: 0...1)
            
            // initialize age
            pointer[index].data.y = UInt32.random(in: 20...40)
            
            // initialize position
            let mapNodeIndex = index % ((self.blockCount + 1) * (self.blockCount + 1))
            let blockLength = Float(self.blockCount) * self.blockSideLength
            let intervalLength = Float(self.blockCount) * self.blockDistance
            let origin = simd_float3(
                repeating: -(blockLength + intervalLength) * 0.5
            )
            let x = mapNodeIndex % (self.blockCount + 1)
            let z = mapNodeIndex / (self.blockCount + 1)
            pointer[index].position = simd_float4(
                Float(x) * (self.blockSideLength + self.blockDistance) + origin.x, 0.0,
                Float(z) * (self.blockSideLength + self.blockDistance) + origin.z, 0.0
            )
            pointer[index].position.x += self.blockSideLength * Float.random(in: -0.3...0.3)
            pointer[index].position.z += self.blockSideLength * Float.random(in: -0.3...0.3)
            
            // initialize destination
            pointer[index].destination = pointer[index].position
            pointer[index].destination.x += 0.1
            pointer[index].destination.z += 0.1
            pointer[index].data.w = UInt32(mapNodeIndex)
        }
        
        // create a private storage buffer
        self.characterBuffer = self.device.makeBuffer(
            length: MemoryLayout<CharacterData>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character buffer
        self.characterBuffer.label = "CharacterBuffer"
        
        // copy data from the staging buffer to the private storage buffer
        let commandQueue = self.device.makeCommandQueue()!
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeBlitCommandEncoder()!
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0,
            to: self.characterBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.endEncoding()
        command.commit()
        command.waitUntilCompleted()
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
        
        // update the map data
        pointer.pointee.mapData = simd_uint4(
            UInt32(self.blockCount),
            0, 0, 0
        )
        
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
        
        pointer.pointee.gridData = simd_uint4(
            UInt32(self.mapGridCount),
            UInt32(self.linkedGridCount),
            UInt32(self.maxNumCharactersPerGrid),
            0
        )
        
        pointer.pointee.gridLengthData = simd_float4(
            Float32(self.gridLengthX),
            Float32(self.gridLengthZ),
            0.0,
            0.0
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
        self.linkedGridCount = (self.characterCount + self.maxNumCharactersPerGrid - 1) / self.maxNumCharactersPerGrid
        
        // create a private storage buffer
        self.characterCountPerGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character count per grid buffer
        self.characterCountPerGridBuffer.label = "CharacterCountPerGridBuffer"
        
        // create a private storage buffer
        self.characterCountPerLinkedGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character count per linked grid buffer
        self.characterCountPerLinkedGridBuffer.label = "CharacterCountPerLinkedGridBuffer"
        
        // create a private storage buffer
        self.initialCharacterCountPerGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the initial character count per grid buffer
        self.initialCharacterCountPerGridBuffer.label = "InitialCharacterCountPerGridBuffer"
        
        // create a private storage buffer
        self.gridDataBuffer = self.device.makeBuffer(
            length: MemoryLayout<GridData>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .storageModePrivate,
            ]
        )!
        // update the label of the grid data buffer
        self.gridDataBuffer.label = "GridDataBuffer"
        
        // create a staging buffer with the initial grid data buffer
        let stagingBuffer = self.device.makeBuffer(
            length: MemoryLayout<GridData>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // acquire the pointer to the staging buffer
        let pointer = stagingBuffer.contents().bindMemory(
            to: GridData.self, capacity: (self.mapGridCount + self.linkedGridCount)
        )
        
        for index in 0...(self.mapGridCount + self.linkedGridCount) {
            pointer[index].next.x = -1
        }
        
        // create a shared storage buffer
        self.initialGridDataBuffer = self.device.makeBuffer(
            length: MemoryLayout<GridData>.stride * (self.mapGridCount + self.linkedGridCount),
            options: [
                .storageModePrivate
            ]
        )!
        // update the label of the initial grid data buffer
        self.initialGridDataBuffer.label = "InitialGridDataBuffer"
        
        // copy data from the staging buffer to the two private storage buffers
        let commandQueue = self.device.makeCommandQueue()!
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeBlitCommandEncoder()!
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0,
            to: self.initialGridDataBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0,
            to: self.gridDataBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.endEncoding()
        command.commit()
        command.waitUntilCompleted()
    }
    
    // define the function that creates the character index buffer per grid
    func createCharacterIndexBufferPerGrid() {
        
        // create a private storage buffer
        self.characterIndexBufferPerGrid = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * (self.mapGridCount + self.linkedGridCount) * self.maxNumCharactersPerGrid,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.characterIndexBufferPerGrid.label = "CharacterIndexBufferPerGrid"
        
        // create a staging buffer with the initial atomic int for next available grid index
        let stagingBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 1,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // acquire the pointer to the staging buffer
        let pointer = stagingBuffer.contents().bindMemory(
            to: UInt32.self, capacity: 1
        )
        
        pointer.pointee = UInt32(mapGridCount)
        
        // create a private storage buffer
        self.initialNextAvailableGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 1,
            options: [
                .storageModePrivate
            ]
        )!
        
        // update the label of the initial atomic int next available grid buffer
        self.initialNextAvailableGridBuffer.label = "InitialNextAvailableGridBuffer"
        
        // copy data from the staging buffer to the private storage buffer
        let commandQueue = self.device.makeCommandQueue()!
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeBlitCommandEncoder()!
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0,
            to: self.initialNextAvailableGridBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.endEncoding()
        command.commit()
        command.waitUntilCompleted()
        
        // create a private storage buffer
        self.nextAvailableGridBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 1,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the initial atomic int next available grid buffer
        self.nextAvailableGridBuffer.label = "NextAvailableGridBuffer"
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
    
    // define the function that creates the map node buffer
    func createMapNodeBuffer() {
        
        // create a staging buffer with the map node data
        let stagingBuffer = self.device.makeBuffer(
            bytes: self.mapNodes, length: MemoryLayout<MapNodeData>.stride * self.mapNodes.count,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // create a private storage buffer
        self.mapNodeBuffer = self.device.makeBuffer(
            length: MemoryLayout<MapNodeData>.stride * self.mapNodes.count,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the map node buffer
        self.mapNodeBuffer.label = "MapNodeBuffer"
        
        // copy data from the staging buffer to the private storage buffer
        let commandQueue = self.device.makeCommandQueue()!
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeBlitCommandEncoder()!
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0, 
            to: self.mapNodeBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.endEncoding()
        command.commit()
        command.waitUntilCompleted()
        
        // clear the array of map nodes
        self.mapNodes.removeAll()
    }
}
