
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
    
    // define the function that creates the simulation pipeline
    func createSimulationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "SimulationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.simulationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the observation pipeline
    func createObservationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "ObservationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.observationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the initialize indirect buffer pipeline
    func createInitializeIndirectBufferPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "InitializeIndirectBufferFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.initializeIndirectBufferPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the physics simulation pipeline
    func createPhysicsSimulationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "PhysicsSimulationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
        
        // create the compute pipeline state
        self.physicsSimulationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the navigation pipeline
    func createNavigationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "NavigationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
        
        // create the compute pipeline state
        self.navigationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the socialization pipeline
    func createSocializationPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "SocializationFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
        
        // create the compute pipeline state
        self.socializationPipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the entertainment entrance pipeline
    func createEntertainmentEntrancePipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "EntertianmentEntranceFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
        
        // create the compute pipeline state
        self.entertainmentEntrancePipeline = try! self.device.makeComputePipelineState(
            descriptor: descriptor, options: []
        ).0
    }
    
    // define the function that creates the entertainment exit pipeline
    func createEntertainmentExitPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "EntertianmentExitFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = false
        
        // create the compute pipeline state
        self.entertainmentExitPipeline = try! self.device.makeComputePipelineState(
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
    
    // define the function that creates the initialize grid pipeline
    func createInitializeGridPipeline() {
        
        // acquire the function from the library
        let function = self.library.makeFunction(name: "InitializeGridFunction")
        
        // define the compute pipline descriptor
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = function
        descriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
        
        // create the compute pipeline state
        self.initializeGridPipeline = try! self.device.makeComputePipelineState(
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
        
        // create an array of characters
        var characters: [CharacterData] = []
        
        // initialize the characters
        for bedBuildingIndex in self.bedData.keys {
            
            // define the index of the nearest office building
            var nearestOfficeBuildingIndex = -1
            
            // find the index of the nearest office building
            if (!self.officeData.isEmpty) {
                var nearestDistance = Float.greatestFiniteMagnitude
                nearestOfficeBuildingIndex = self.officeData.keys.randomElement()!
                for officeBuildingIndex in self.officeData.keys {
                    let currentDistance = distance(
                        self.buildings[officeBuildingIndex].position,
                        self.buildings[bedBuildingIndex].position
                    )
                    if (nearestDistance > currentDistance) {
                        nearestDistance = currentDistance
                        nearestOfficeBuildingIndex = officeBuildingIndex
                    }
                }
            }
            
            // iterate through all the bed data
            for bedData in self.bedData[bedBuildingIndex]! {
                
                // create a new character
                var character = CharacterData()
                
                // initialize gender
                character.data.x = UInt32.random(in: 0...1)
                
                // initialize age
                character.data.y = UInt32.random(in: 20...40)
                
                // initialize the personalities
                character.personalities = normalize(simd_float4(
                    Float.random(in: -1.0...1.0),
                    Float.random(in: -1.0...1.0),
                    Float.random(in: -1.0...1.0),
                    0.0
                ))
                
                // initialize the stats
                character.stats.0 = Float.random(in: 0.0...1.0)
                character.stats.1 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
                character.stats.2 = 1.0 / (Float.random(in: 120.0...180.0) * 60.0)
                character.stats.3 = Float.random(in: 0.0...200.0)
                character.stats.4 = Bool.random() ? 0.0 : 200.0
                character.stats.5 = self.officeData.isEmpty ? 0.0 : Float.random(in: 100.0...200.0)
                character.stats.6 = character.stats.5 / (Float.random(in: 12.0...18.0) * 60.0)
                character.stats.7 = Float.random(in: 0.0...1.0)
                character.stats.8 = 1.0 / (Float.random(in: 24.0...36.0) * 60.0)
                character.stats.9 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
                character.stats.10 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
                
                // initialize the addresses
                character.addresses.0 = bedData
                character.addresses.1 = bedData
                character.addresses.2 = simd_int4(repeating: -1)
                
                // find the next nearest office building index
                if (nearestOfficeBuildingIndex == -1 && !self.officeData.isEmpty) {
                    var nearestDistance = Float.greatestFiniteMagnitude
                    for officeBuildingIndex in self.officeData.keys {
                        let currentDistance = distance(
                            self.buildings[officeBuildingIndex].position,
                            self.buildings[bedBuildingIndex].position
                        )
                        if (nearestDistance > currentDistance) {
                            nearestDistance = currentDistance
                            nearestOfficeBuildingIndex = officeBuildingIndex
                        }
                    }
                }
                
                // assign the nearest office data to the character
                if (nearestOfficeBuildingIndex != -1) {
                    character.addresses.2 = self.officeData[nearestOfficeBuildingIndex]!.randomElement()!
                    self.officeData[nearestOfficeBuildingIndex]!.remove(character.addresses.2)
                    if (self.officeData[nearestOfficeBuildingIndex]!.isEmpty) {
                        self.officeData[nearestOfficeBuildingIndex] = nil
                        nearestOfficeBuildingIndex = -1
                    }
                }
                
                // initialize the navigation data
                character.navigation = simd_int4(
                    -1, -1,
                     Int32(bedData.y),
                     Int32(bedData.y)
                )
                
                // initialize position
                character.position = self.mapNodes[Int(bedData.y)].position
                
                // initialize destination
                character.destination = character.position
                
                // store the new character
                characters.append(character)
            }
        }
        
        // iterate through all the service workers bed data
        for serviceIndustryWorkersData in self.serviceIndustryWorkersData {
            
            // create a new character
            var character = CharacterData()
            
            // initialize gender
            character.data.x = UInt32.random(in: 0...1)
            
            // initialize age
            character.data.y = UInt32.random(in: 20...40)
            
            // initialize occupation
            character.data.z = 1
            
            // initialize the personalities
            character.personalities = normalize(simd_float4(
                Float.random(in: -1.0...1.0),
                Float.random(in: -1.0...1.0),
                Float.random(in: -1.0...1.0),
                0.0
            ))
            
            // initialize the stats
            character.stats.0 = Float.random(in: 0.0...1.0)
            character.stats.1 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
            character.stats.2 = 1.0
            character.stats.3 = Float.random(in: 0.0...200.0)
            character.stats.4 = Bool.random() ? 0.0 : 200.0
            character.stats.5 = self.officeData.isEmpty ? 0.0 : Float.random(in: 100.0...200.0)
            character.stats.6 = character.stats.5 / (Float.random(in: 12.0...18.0) * 60.0)
            character.stats.7 = Float.random(in: 0.0...1.0)
            character.stats.8 = 1.0 / (Float.random(in: 24.0...36.0) * 60.0)
            character.stats.9 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
            character.stats.10 = 1.0 / (Float.random(in: 12.0...18.0) * 60.0)
            
            // initialize the addresses
            character.addresses.0 = serviceIndustryWorkersData.0
            character.addresses.1 = serviceIndustryWorkersData.0
            character.addresses.2 = serviceIndustryWorkersData.1
            
            // initialize the navigation data
            character.navigation = simd_int4(
                -1, -1,
                 Int32(serviceIndustryWorkersData.0.y),
                 Int32(serviceIndustryWorkersData.0.y)
            )
            
            // initialize position
            character.position = self.mapNodes[Int(serviceIndustryWorkersData.0.y)].position
            
            // initialize destination
            character.destination = character.position
            
            // store the new character
            characters.append(character)
        }
        
        // update the total number of characters
        self.characterCount = characters.count
        
        // create a staging buffer with the map node data
        let stagingBuffer = self.device.makeBuffer(
            bytes: characters, length: MemoryLayout<CharacterData>.stride * self.characterCount,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // create a private storage buffer
        self.characterBuffer = self.device.makeBuffer(
            length: stagingBuffer.length,
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
        
        // clear the array of bed data
        self.bedData.removeAll()
        
        // clear the set of office data
        self.officeData.removeAll()
        
        // clear the array of map nodes
        self.mapNodes.removeAll()
        
        // clear the building data
        self.buildings.removeAll()
        
        // create the character indirect buffer
        self.characterIndirectBuffer = self.device.makeBuffer(
            length: MemoryLayout<MTLDispatchThreadgroupsIndirectArguments>.stride * 10,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.characterIndirectBuffer.label = "CharacterIndirectBuffer"
        
        // create the character count buffer
        self.characterCountBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * 10,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.characterCountBuffer.label = "CharacterCountBuffer"
        
        // create a private storage buffer
        self.physicsSimulationCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.physicsSimulationCharacterIndexBuffer.label = "PhysicsSimulationCharacterIndexBuffer"
        
        // create a private storage buffer
        self.navigationCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.navigationCharacterIndexBuffer.label = "NavigationCharacterIndexBuffer"
        
        // create a private storage buffer
        self.socializationCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.socializationCharacterIndexBuffer.label = "SocializationCharacterIndexBuffer"
        
        // create a private storage buffer
        self.entertainmentEntranceCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.entertainmentEntranceCharacterIndexBuffer.label = "EntertainmentEntranceCharacterIndexBuffer"
        
        // create a private storage buffer
        self.entertainmentExitCharacterIndexBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the buffer
        self.entertainmentExitCharacterIndexBuffer.label = "EntertainmentExitCharacterIndexBuffer"
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
        
        // update the zombification indicator
        pointer.pointee.data.z = self.zombification ? 1.0 : 0.0
        self.zombification = false
        
        // update the grid data
        pointer.pointee.gridCountData.x = UInt32(self.gridCount)
        pointer.pointee.gridLengthData.x = self.gridLength
        
        // update the block data
        pointer.pointee.blockCountData.x = UInt32(self.blockCount)
        pointer.pointee.blockLengthData.x = self.blockSideLength
        pointer.pointee.blockLengthData.y = self.blockDistance
        
        // update the character data
        self.characterGroupIndex = (self.characterGroupIndex + 1) % 30
        pointer.pointee.characterData = simd_uint4(
            UInt32(self.characterCount),
            UInt32(self.visibleCharacterCount),
            UInt32(self.actualVisibleCharacterCount),
            UInt32(self.characterGroupIndex)
        )
        
        // update the position of the observer
        pointer.pointee.observerPosition = simd_float4(
            self.observerPosition, 1.0
        )
        
        // update the frustum data
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
            length: MemoryLayout<UInt32>.stride * self.gridCount * self.gridCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character count per grid buffer
        self.characterCountPerGridBuffer.label = "CharacterCountPerGridBuffer"
        
        // create a private storage buffer
        self.gridDataBuffer = self.device.makeBuffer(
            length: MemoryLayout<GridData>.stride * self.gridCount * self.gridCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the grid data buffer
        self.gridDataBuffer.label = "GridDataBuffer"
    }
    
    // define the function that creates the character index buffer per grid
    func createCharacterIndexBufferPerGrid() {
        
        // create a private storage buffer
        self.characterIndexBufferPerGrid = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.characterCount,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the visible character index buffer
        self.characterIndexBufferPerGrid.label = "CharacterIndexBufferPerGrid"
        
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
        
        // copy device visibleCharacterCountBuffer to host
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
        
        // clear the connection data
        self.exteriorConnectionData.removeAll()
    }
    
    // define the function that creates the building buffer
    func createBuildingBuffer() {
        
        // create a staging buffer with the building data
        let stagingBuffer = self.device.makeBuffer(
            bytes: self.buildings, length: MemoryLayout<BuildingData>.stride * self.buildings.count,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // create a private storage buffer
        self.buildingBuffer = self.device.makeBuffer(
            length: MemoryLayout<BuildingData>.stride * self.buildings.count,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the building buffer
        self.buildingBuffer.label = "BuildingBuffer"
        
        // copy data from the staging buffer to the private storage buffer
        let commandQueue = self.device.makeCommandQueue()!
        let command = commandQueue.makeCommandBuffer()!
        let encoder = command.makeBlitCommandEncoder()!
        encoder.copy(
            from: stagingBuffer, sourceOffset: 0,
            to: self.buildingBuffer, destinationOffset: 0,
            size: stagingBuffer.length
        )
        encoder.endEncoding()
        command.commit()
        command.waitUntilCompleted()
        
        // create a private storage buffer
        self.characterCountPerBuildingBuffer = self.device.makeBuffer(
            length: MemoryLayout<UInt32>.stride * self.buildings.count,
            options: [
                .storageModePrivate,
            ]
        )!
        
        // update the label of the character count per building buffer
        self.characterCountPerBuildingBuffer.label = "CharacterCountPerBuildingBuffer"
    }
}
