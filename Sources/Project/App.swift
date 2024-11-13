
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
    let characterCount: Int = 400
    
    // define the total number of visible characters
    let visibleCharacterCount: Int = 400
    
    // define the graphics device
    var device: MTLDevice!
    
    // define the command queue
    var commandQueue: MTLCommandQueue!
    
    // define the renderer instance
    var renderer: Renderer!
    
    // define the simulation instance
    var simulator: Citopia!
    
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
            capacity: (1000000, 1000)
        )
        MeshManager.configure(
            capacity: (100, 1000000, 1000000, 10000, 1000000, 1)
        )
        MotionManager.configure(
            capacity: (1000000, 100000, 1000000, 100000)
        )
        CameraManager.configure(
            capacity: 10
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
        self.simulator = Citopia(device: self.device)
        
        // create the simulation characters
        self.simulator.createCharacters(
            characterCount: self.characterCount,
            visibleCharacterCount: self.visibleCharacterCount,
            visibleCharacterBuffer: self.renderer.visibleCharacterBuffer.0
        )
        
        self.simulator.createGrids()
    }
    
    // define the update behavior
    override func updated(state: Int) {
        
        // define the behavior of the primary update state
        if (state == 0) {
            
            // create a new command buffer
            let commandBuffer = self.commandQueue.makeCommandBuffer()!
            
            // perform the simulation
            self.simulator.simulate(time: App.time, commandBuffer: commandBuffer)
            
            // submit the command buffer
            commandBuffer.commit()
            
            // wait until all commands have been completed
            commandBuffer.waitUntilCompleted()
            
            // perform rendering
            self.renderer.render()
            
            // transfer the frustum planes
            self.simulator.frustumPlanes = self.renderer.generateFrustumPlanes()
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
    }
    
    // define the key up behavior
    override func removed(press: String) {
        
        // remove the press
        self.renderer.remove(press: press)
    }
}
