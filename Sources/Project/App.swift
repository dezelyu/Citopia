
// import the custom game engine
import ApplicationKit
import GraphicsKit
import AssetKit
import NodeKit
import MeshKit
import MotionKit
import CameraKit

// define the application class
@main class App: Application {
    
    // define the total number of characters to simulate
    let characterCount: Int = 100000
    
    // define the total number of visible characters
    let visibleCharacterCount: Int = 400
    
    // define the number of blocks per row of the map
    let blockCount: Int = 100
    
    // define the side length of the block in meters
    let blockSideLength: Float = 16
    
    // define the distance between two blocks in meters
    let blockDistance: Float = 12
    
    // define the graphics device
    var device: MTLDevice!
    
    // define the command queue
    var commandQueue: MTLCommandQueue!
    
    // define the renderer instance
    var renderer: Renderer!
    
    // define the simulation instance
    var simulator: Citopia!
    
    // define an array of simulation durations
    var simulationDurations: [CFTimeInterval] = []
    
    // define the launching behavior
    override func launched() {
        
        // lock the cursor
        Cursor.lock()
        
        // show performance statistics
        App.view?.showsStatistics = true
        
        // configure the game engine frameworks
        GraphicsManager.configure()
        AssetManager.configure(
            name: String(),
            data: String()
        )
        NodeManager.configure(
            capacity: (2000000, 1000)
        )
        MeshManager.configure(
            capacity: (100, 1000000, 1000000, 10000, 1000000, 1)
        )
        MotionManager.configure(
            capacity: (1000000, 100000, 1000000, 100000)
        )
        CameraManager.configure(
            capacity: 2
        )
        
        // store the graphics device
        self.device = App.view?.device
        
        // create a new command queue
        self.commandQueue = self.device.makeCommandQueue()
        
        // create a new renderer instance
        self.renderer = Renderer()
        
        // create the visible characters
        self.renderer.createCharacters(
            visibleCharacterCount: self.visibleCharacterCount,
            device: self.device
        )
        
        // create a new simulation instance
        self.simulator = Citopia(
            device: self.device,
            characterCount: self.characterCount,
            visibleCharacterCount: self.visibleCharacterCount,
            blockCount: self.blockCount,
            blockSideLength: self.blockSideLength,
            blockDistance: self.blockDistance
        )
        
        // generate the exterior map
        self.simulator.generateExteriorMap()
        
        // generate the buildings
        self.simulator.generateBuildings()
        
        // create the map node buffer
        self.simulator.createMapNodeBuffer()
        
        // create the building buffer
        self.simulator.createBuildingBuffer()
        
        // create the simulation characters
        self.simulator.createCharacters(
            visibleCharacterBuffer: self.renderer.visibleCharacterBuffer.0
        )
        
        // create the grid acceleration structure
        self.simulator.createGrids()
        
        // create the buildings
        self.renderer.createBuildings(
            buildingBlocks: self.simulator.buildingBlocks
        )
        
        // create the furnitures
        self.renderer.createFurnitures(
            furnitureBlocks: self.simulator.furnitureBlocks
        )
        
        // free up some memory
        self.simulator.buildingBlocks.removeAll()
        self.simulator.furnitureBlocks.removeAll()
    }
    
    // define the update behavior
    override func updated(state: Int) {
        
        // define the behavior of the primary update state
        if (state == 0) {
            
            // create a new command buffer
            let commandBuffer = self.commandQueue.makeCommandBuffer()!
            
            // perform the simulation
            self.simulator.simulate(time: App.time, commandBuffer: commandBuffer)
            
            // record the start time
            let startTime = CACurrentMediaTime()
            
            // submit the command buffer
            commandBuffer.commit()
            
            // compute the simulation duration
            commandBuffer.addCompletedHandler { _ in
                let endTime = CACurrentMediaTime()
                let simulationDuration = (endTime - startTime) * 1000.0
                self.simulationDurations.append(simulationDuration)
                if (self.simulationDurations.count > 100) {
                    self.simulationDurations.removeFirst()
                    var averageSimulationDuration: CFTimeInterval = 0.0
                    for simulationDuration in self.simulationDurations {
                        averageSimulationDuration += simulationDuration
                    }
                    averageSimulationDuration /= CFTimeInterval(self.simulationDurations.count)
                    
                    // print the average simulation duration
                    // print("Simulation Duration: \(averageSimulationDuration)ms")
                }
            }
            
            // wait until all commands have been completed
            commandBuffer.waitUntilCompleted()
            
            // perform rendering
            self.renderer.render()
            
            // transfer the frustum planes
            self.simulator.frustumPlanes = self.renderer.generateFrustumPlanes()
            
            // update observer position
            self.simulator.observerPosition = self.renderer.cameraNode.position
            
            // perform sorting
            self.simulator.sortVisibleCharacterIndexBufferByDistance()
        }
    }
    
    // define the hover behavior
    override func hovered(delta: CGVector) {
        
        // update the target rotation of the camera
        self.renderer.updateTargetRotation(delta: delta)
    }
    
    // define the key down behavior
    override func started(press: String) {
        
        // record the press
        self.renderer.start(press: press)
        
        // check for zombification
        if (press.lowercased() == "z") {
            self.simulator.zombification = true
        }
    }
    
    // define the key up behavior
    override func removed(press: String) {
        
        // remove the press
        self.renderer.remove(press: press)
    }
}
