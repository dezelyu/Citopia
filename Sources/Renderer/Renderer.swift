
// import the custom game engine
import ApplicationKit
import GraphicsKit
import AssetKit
import NodeKit
import MeshKit
import MotionKit
import CameraKit

// define the class for rendering the simulation
class Renderer {
    
    // define the current phase index
    var phase: Int = 0
    
    // define the active keys
    var activeKeys: Set<String> = []
    
    // define the target position
    var targetPosition: simd_float3 = .zero
    
    // define the target rotation
    var targetRotation: simd_float3 = .zero
    
    // define the camera node
    var cameraNode: CameraNode!
    
    // define the directional feedback nodes
    var centerNode: FeedbackNode!
    var forwardNode: FeedbackNode!
    var leftNode: FeedbackNode!
    var upNode: FeedbackNode!
    
    // define the render targets
    var attachment: (Attachment, Attachment)!
    
    // define the commands
    var commands: [Command] = []
    
    // define the container for all the mesh nodes
    var meshNodes: [MeshNode] = []
    
    // define the constructor
    init() {
        
        // create the camera node
        self.cameraNode = CameraNode(
            category: 1, angle: 60.0, near: 0.01, far: 1000.0
        )
        
        // create the directional feedback nodes
        self.centerNode = FeedbackNode()
        self.forwardNode = FeedbackNode()
        self.leftNode = FeedbackNode()
        self.upNode = FeedbackNode()
        
        // position the directional feedback nodes
        self.forwardNode.position = simd_float3(0.0, 0.0, -0.5)
        self.leftNode.position = simd_float3(-0.5, 0.0, 0.0)
        self.upNode.position = simd_float3(0.0, 0.5, 0.0)
        
        // attach the directional feedback nodes to the camera
        self.cameraNode.attach(node: self.centerNode)
        self.cameraNode.attach(node: self.forwardNode)
        self.cameraNode.attach(node: self.leftNode)
        self.cameraNode.attach(node: self.upNode)
        
        // attach the camera node to the scene
        NodeManager.attach(node: self.cameraNode)
        
        // create the render targets
        self.attachment = CameraManager.attachment(scale: 2.0)
        
        // create the commands
        self.commands = [
            Command(),
            Command(),
            Command(),
        ]
        
        // configure the present behavior
        CameraManager.present(
            camera: self.cameraNode,
            attachment: self.attachment,
            prerequisite: (
                [self.commands[0]],
                [self.commands[1]],
                [self.commands[2]]
            )
        )
    }
    
    // define the character creator
    func createCharacters(visibleCharacterCount: Int) {
        
        // define the names of the scene assets to load
        let names = [
            "Assets.scnassets/Character/Female0.scn",
            "Assets.scnassets/Character/Female1.scn",
            "Assets.scnassets/Character/Female2.scn",
            "Assets.scnassets/Character/Female3.scn",
            "Assets.scnassets/Character/Male0.scn",
            "Assets.scnassets/Character/Male1.scn",
            "Assets.scnassets/Character/Male2.scn",
            "Assets.scnassets/Character/Male3.scn",
            "Assets.scnassets/Character/Skeleton.scn",
        ]
        
        // load the scene assets
        let sceneAssets = names.map { name in
            return SceneAsset(name: name)
        }
        
        // load the mesh assets
        let meshAssets = sceneAssets.dropLast().map { sceneAsset in
            return sceneAsset.meshes.first!
        }
        
        // load the meshes from the mesh assets
        let meshes = [
            Mesh(asset: meshAssets[0], scale: 2.0, range: (0.0, 0.0, 2.0, 2.5)),
            Mesh(asset: meshAssets[1], scale: 2.0, range: (1.5, 2.0, 5.0, 6.0)),
            Mesh(asset: meshAssets[2], scale: 2.0, range: (4.0, 5.0, 10.0, 11.0)),
            Mesh(asset: meshAssets[3], scale: 2.0, range: (9.0, 10.0, 1000.0, 1000.0)),
            Mesh(asset: meshAssets[4], scale: 2.0, range: (0.0, 0.0, 2.0, 2.5)),
            Mesh(asset: meshAssets[5], scale: 2.0, range: (1.5, 2.0, 5.0, 6.0)),
            Mesh(asset: meshAssets[6], scale: 2.0, range: (4.0, 5.0, 10.0, 11.0)),
            Mesh(asset: meshAssets[7], scale: 2.0, range: (9.0, 10.0, 1000.0, 1000.0)),
        ]
        
        // load the skeleton node
        let skeleton = sceneAssets.last!.root
        
        // iterate from one to the visible character count
        for index in 1...max(1, visibleCharacterCount) {
            
            // create a new root for the character
            let characterNode = Node()
            
            // attach the skeleton to the character
            characterNode.attach(node: Node(node: skeleton))
            
            // load the female meshes
            for index in 0...3 {
                let meshNode = MeshNode(mesh: meshes[index], category: 1)
                self.meshNodes.append(meshNode)
                characterNode.attach(node: meshNode)
            }
            
            // load the male meshes
            for index in 4...7 {
                let meshNode = MeshNode(mesh: meshes[index], category: 1)
                self.meshNodes.append(meshNode)
                characterNode.attach(node: meshNode)
            }
            
            // position the character node
            characterNode.position = simd_float3(Float(index) * 2.0, 0.0, 0.0)
            
            // scale the character node
            characterNode.scale = simd_float3(repeating: 0.01)
            
            // attach the character node to the scene
            NodeManager.attach(node: characterNode)
        }
    }
    
    // define the render
    func render() {
        
        // update the current phase index
        self.phase = (self.phase + 1) % 3
        
        // wait for the previous command to finish
        self.commands[self.phase].complete()
        
        // update the target position of the camera
        self.updateTargetPosition()
        
        // move and rotate the camera smoothly
        self.cameraNode.position += (self.targetPosition - self.cameraNode.position) * 0.2
        self.cameraNode.rotation += (self.targetRotation - self.cameraNode.rotation) * 0.2
        
        // perform rendering
        MeshManager.update()
        MotionManager.sample(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        MotionManager.animate(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        NodeManager.transform(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        CameraManager.update(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        self.cameraNode.capture(command: self.commands[self.phase], color: [
            self.attachment.0.clear().store(),
        ], depth: self.attachment.1.clear().store())
        self.commands[self.phase].commit()
    }
}
