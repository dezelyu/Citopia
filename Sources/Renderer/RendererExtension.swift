
// import the custom game engine
import ApplicationKit
import GraphicsKit
import AssetKit
import NodeKit
import MeshKit
import MotionKit
import CameraKit

// define the class extension for all the utility functions
extension Renderer {
    
    // define the function that updates the target rotation of the camera
    func updateTargetPosition() {
        
        // compute the directional vectors
        let forward = self.forwardNode.feedback()[3] - self.centerNode.feedback()[3]
        let left = self.leftNode.feedback()[3] - self.centerNode.feedback()[3]
        let up = self.upNode.feedback()[3] - self.centerNode.feedback()[3]
        
        // update the target position of the camera
        if (self.activeKeys.contains("w")) {
            self.targetPosition += simd_float3(forward.x, forward.y, forward.z)
        }
        if (self.activeKeys.contains("s")) {
            self.targetPosition -= simd_float3(forward.x, forward.y, forward.z)
        }
        if (self.activeKeys.contains("a")) {
            self.targetPosition += simd_float3(left.x, left.y, left.z)
        }
        if (self.activeKeys.contains("d")) {
            self.targetPosition -= simd_float3(left.x, left.y, left.z)
        }
        if (self.activeKeys.contains("e")) {
            self.targetPosition += simd_float3(up.x, up.y, up.z)
        }
        if (self.activeKeys.contains("q")) {
            self.targetPosition -= simd_float3(up.x, up.y, up.z)
        }
    }
    
    // define the function that updates the target rotation of the camera
    func updateTargetRotation(delta: CGVector) {
        
        // define the sensitivity
        let sensitivity = Float(0.01)
        
        // update the target rotation of the camera
        self.targetRotation.y -= Float(delta.dx) * sensitivity
        self.targetRotation.x += Float(delta.dy) * sensitivity
    }
    
    // define the function that updates the position of the ground
    func updateGroundPosition() {
        self.groundNode.position.x = Float(Int(self.cameraNode.position.x) / 100) * 100.0
        self.groundNode.position.z = Float(Int(self.cameraNode.position.z) / 100) * 100.0
    }
    
    // define the function that stores the new active key
    func start(press: String) {
        self.activeKeys.insert(press.lowercased())
    }
    
    // define the function that removes the new active key
    func remove(press: String) {
        self.activeKeys.remove(press.lowercased())
    }
}
