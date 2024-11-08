
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
    
    // define the launching behavior
    override func launched() {
        
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
    }
}
