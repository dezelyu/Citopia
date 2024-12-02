
// import the custom game engine
import ApplicationKit
import GraphicsKit
import AssetKit
import NodeKit
import MeshKit
import MotionKit
import CameraKit

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = sex
    //  - data.w = character node index
    var data: simd_uint4 = .zero
    
    // define the personalities of the character
    var personalities: simd_float4 = .zero
    
    // define the indices of the female mesh nodes
    var femaleMeshNodeIndices: simd_uint4 = .zero
    
    // define the indices of the male mesh nodes
    var maleMeshNodeIndices: simd_uint4 = .zero
    
    // define the transform of the visible character
    var transform: simd_float4x4 = simd_float4x4(1.0)
    
    // define the motion controller indices
    var motionControllerIndices: (
        Int32, Int32, Int32, Int32, Int32,
        Int32, Int32, Int32, Int32, Int32,
        Int32, Int32, Int32, Int32, Int32,
        Int32, Int32, Int32, Int32, Int32,
        Int32, Int32, Int32, Int32, Int32
    ) = (
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1
    )
    
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
    
    // define the debug camera node
    var debugCameraNode: CameraNode!
    
    // define the camera instance
    var camera: SCNCamera!
    
    // define the viewport size
    var size: CGSize!
    
    // define the directional feedback nodes
    var centerNode: FeedbackNode!
    var forwardNode: FeedbackNode!
    var leftNode: FeedbackNode!
    var upNode: FeedbackNode!
    
    // define the render targets
    var attachment: (Attachment, Attachment)!
    
    // define the commands
    var commands: [Command] = []
    
    // define the update compute pipeline
    var updateComputePipeline: ComputePipeline!
    
    // define the present pipeline
    var presentPipeline: RenderPipeline!
    
    // define the total number of visible characters
    var visibleCharacterCount: Int = 0
    
    // define the buffer for the visible characters
    var visibleCharacterBuffer: (MTLBuffer, GenericBuffer)!
    
    // define the container for all the mesh nodes
    var meshNodes: [MeshNode] = []
    
    // define the container for all the motion nodes
    var motionNodes: [MotionNode] = []
    
    // define the ground node
    var groundNode: Node!
    
    // define the decoration visibility
    var decorationVisibility: Bool = true
    
    // define the constructor
    init() {
        
        // create the camera node
        self.cameraNode = CameraNode(
            category: 3, angle: 60.0, near: 0.5, far: 500.0
        )
        
        // create the debug camera node
        self.debugCameraNode = CameraNode(
            category: 1, angle: 60.0, near: 0.5, far: 500.0
        )
        
        // create the camera instance
        self.camera = SCNCamera()
        self.camera.fieldOfView = 60.0
        self.camera.zNear = 0.5
        self.camera.zFar = 500.0
        
        // acquire the viewport size
        self.size = Application.view!.frame.size
        
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
        
        // specify the initial position and rotation of the camera
        self.targetPosition.y = 100.0
        self.targetRotation = simd_float3(-0.5, Float.pi * 0.25, 0.0)
        self.cameraNode.position = simd_float3(500.0, 800.0, 500.0)
        self.cameraNode.rotation = simd_float3(-0.5, Float.pi * 0.25, 0.0)
        
        // attach the camera node to the scene
        NodeManager.attach(node: self.cameraNode)
        
        // attach the debug camera node to the scene
        NodeManager.attach(node: self.debugCameraNode)
        
        // create the render targets
        self.attachment = CameraManager.attachment(scale: 2.0)
        
        // create the commands
        self.commands = [
            Command(),
            Command(),
            Command(),
        ]
        
        // create a new library
        let library = Library(bundle: Bundle(for: Renderer.self))
        
        // create the update compute pipeline
        self.updateComputePipeline = ComputePipeline(
            function: Function(library: library, name: "UpdateFunction")
        )
        
        // create the present pipeline
        self.presentPipeline = RenderPipeline(
            function: Function(library: library, name: "PresentFragmentFunction")
        )
        
        // create the ground node
        self.groundNode = Node()
        NodeManager.attach(node: self.groundNode)
        
        // create the ground planes
        let groundSceneAsset = SceneAsset(name: "Assets.scnassets/Elements/Ground.scn")
        let groundMeshAsset = groundSceneAsset.meshes.first!
        let groundMesh = Mesh(asset: groundMeshAsset)
        for x in (-10)...10 {
            for z in (-10)...10 {
                let groundMeshNode = MeshNode(
                    mesh: groundMesh, category: 1
                )
                groundMeshNode.position = simd_float3(
                    Float(x) * 100.0, 0.0, Float(z) * 100.0
                )
                groundMeshNode.scale = simd_float3(
                    repeating: 100.0
                )
                groundMeshNode.data.2 = 1
                self.meshNodes.append(groundMeshNode)
                self.groundNode.attach(node: groundMeshNode)
            }
        }
        
        // configure the present behavior
        Presenter.configure(
            pipeline: self.presentPipeline,
            descriptors: [
                CameraBuffer.buffer,
                self.attachment.0,
                self.attachment.1,
            ], prerequisite: (
                [self.commands[0]],
                [self.commands[1]],
                [self.commands[2]]
            )
        )
    }
    
    // define the character creator
    func createCharacters(visibleCharacterCount: Int, device: MTLDevice) {
        
        // store the total number of visible characters
        self.visibleCharacterCount = visibleCharacterCount
        
        // create a new buffer for the visible characters
        let buffer = device.makeBuffer(
            length: MemoryLayout<VisibleCharacterData>.stride * visibleCharacterCount,
            options: [
                .cpuCacheModeWriteCombined,
                .storageModeShared,
            ]
        )!
        
        // acquire a pointer to the buffer
        let pointer = buffer.contents().bindMemory(
            to: VisibleCharacterData.self, capacity: visibleCharacterCount
        )
        
        // define the names of the mesh scene assets to load
        let meshSceneNames = [
            "Assets.scnassets/Characters/Female0.scn",
            "Assets.scnassets/Characters/Female1.scn",
            "Assets.scnassets/Characters/Female2.scn",
            "Assets.scnassets/Characters/Female3.scn",
            "Assets.scnassets/Characters/Male0.scn",
            "Assets.scnassets/Characters/Male1.scn",
            "Assets.scnassets/Characters/Male2.scn",
            "Assets.scnassets/Characters/Male3.scn",
            "Assets.scnassets/Characters/Skeleton.scn",
        ]
        
        // load the mesh scene assets
        let meshSceneAssets = meshSceneNames.map { meshSceneName in
            return SceneAsset(name: meshSceneName)
        }
        
        // load the mesh assets
        let meshAssets = meshSceneAssets.dropLast().map { meshSceneAsset in
            return meshSceneAsset.meshes.first!
        }
        
        // load the meshes from the mesh assets
        let meshes = [
            Mesh(asset: meshAssets[0], scale: 4.0, range: (0.0, 0.0, 2.0, 2.5)),
            Mesh(asset: meshAssets[1], scale: 4.0, range: (1.5, 2.0, 5.0, 6.0)),
            Mesh(asset: meshAssets[2], scale: 4.0, range: (4.0, 5.0, 10.0, 11.0)),
            Mesh(asset: meshAssets[3], scale: 4.0, range: (9.0, 10.0, 1000.0, 1000.0)),
            Mesh(asset: meshAssets[4], scale: 4.0, range: (0.0, 0.0, 2.0, 2.5)),
            Mesh(asset: meshAssets[5], scale: 4.0, range: (1.5, 2.0, 5.0, 6.0)),
            Mesh(asset: meshAssets[6], scale: 4.0, range: (4.0, 5.0, 10.0, 11.0)),
            Mesh(asset: meshAssets[7], scale: 4.0, range: (9.0, 10.0, 1000.0, 1000.0)),
        ]
        
        // load the skeleton node
        let skeleton = meshSceneAssets.last!.root
        
        // define the names of the motion scene assets to load
        let motionSceneNames = [
            ("Assets.scnassets/Motions/IdleLoop0.scn", true, false),
            ("Assets.scnassets/Motions/WalkLoop0.scn", true, false),
            ("Assets.scnassets/Motions/SleepLoop.scn", true, false),
            ("Assets.scnassets/Motions/SleepStart.scn", false, false),
            ("Assets.scnassets/Motions/SleepEnd.scn", false, false),
            ("Assets.scnassets/Motions/WorkLoop.scn", true, false),
            ("Assets.scnassets/Motions/TalkLoop.scn", true, false),
            ("Assets.scnassets/Motions/WalkLoop1.scn", true, false),
            ("Assets.scnassets/Motions/WalkLoop2.scn", true, false),
        ]
        
        // load the motion scene assets
        let motionSceneAssets = motionSceneNames.map { motionSceneName in
            return SceneAsset(name: motionSceneName.0)
        }
        
        // load the motion assets
        let motionAssets = motionSceneAssets.map { motionSceneAsset in
            return motionSceneAsset.motions.first!
        }
        
        // load the motions
        let motions = motionAssets.map { motionAsset in
            return Motion(asset: motionAsset)
        }
        
        // iterate from one to the visible character count
        for index in 1...max(1, visibleCharacterCount) {
            
            // create a new visible character data
            var visibleCharacterData = VisibleCharacterData()
            
            // create a new root for the character
            let characterNode = Node()
            
            // attach the skeleton to the character
            characterNode.attach(node: Node(node: skeleton))
            
            // store the character node index
            visibleCharacterData.data.w = UInt32(characterNode.index())
            
            // load the female meshes
            for index in 0...3 {
                let meshNode = MeshNode(mesh: meshes[index], category: 1)
                self.meshNodes.append(meshNode)
                characterNode.attach(node: meshNode)
                
                // store the female mesh indices
                visibleCharacterData.femaleMeshNodeIndices[index] = UInt32(meshNode.index())
            }
            
            // load the male meshes
            for index in 4...7 {
                let meshNode = MeshNode(mesh: meshes[index], category: 1)
                self.meshNodes.append(meshNode)
                characterNode.attach(node: meshNode)
                
                // store the male mesh indices
                visibleCharacterData.maleMeshNodeIndices[index - 4] = UInt32(meshNode.index())
            }
            
            // load the motions
            for (index, motion) in motions.enumerated() {
                let motionNode = MotionNode(
                    motion: motion,
                    looped: motionSceneNames[index].1,
                    clamped: motionSceneNames[index].2
                )
                characterNode.attach(node: motionNode)
                self.motionNodes.append(motionNode)
                
                // play the first motion
                if (index == 0) {
                    motionNode.play(weight: 1.0, attack: 0.0)
                }
                
                // register the motion controllers
                switch (index - 1) {
                    case 0:
                        visibleCharacterData.motionControllerIndices.0 = Int32(motionNode.data.1)
                        break
                    case 1:
                        visibleCharacterData.motionControllerIndices.1 = Int32(motionNode.data.1)
                        break
                    case 2:
                        visibleCharacterData.motionControllerIndices.2 = Int32(motionNode.data.1)
                        break
                    case 3:
                        visibleCharacterData.motionControllerIndices.3 = Int32(motionNode.data.1)
                        break
                    case 4:
                        visibleCharacterData.motionControllerIndices.4 = Int32(motionNode.data.1)
                        break
                    case 5:
                        visibleCharacterData.motionControllerIndices.5 = Int32(motionNode.data.1)
                        break
                    case 6:
                        visibleCharacterData.motionControllerIndices.6 = Int32(motionNode.data.1)
                        break
                    case 7:
                        visibleCharacterData.motionControllerIndices.7 = Int32(motionNode.data.1)
                        break
                    default:
                        break
                }
                
                // print the duration of the motion
                // print(motionSceneNames[index], motionNode.duration)
            }
            
            // position the character node
            characterNode.position = simd_float3(Float(index) * 2.0, 0.0, 0.0)
            
            // scale the character node
            characterNode.scale = simd_float3(repeating: 0.01)
            
            // store the character transform
            visibleCharacterData.transform = characterNode.transform
            
            // attach the character node to the scene
            NodeManager.attach(node: characterNode)
            
            // store the new visible character data
            pointer[index - 1] = visibleCharacterData
        }
        
        // save the visible character buffer
        self.visibleCharacterBuffer = (
            buffer, GenericBuffer(buffer: buffer)
        )
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
        self.debugCameraNode.transform = self.cameraNode.transform
        
        // update the position of the ground
        self.updateGroundPosition()
        
        // perform rendering
        MeshManager.update()
        self.commands[self.phase].compute(
            pipeline: self.updateComputePipeline,
            descriptors: [
                self.visibleCharacterBuffer.1,
                LocalNodeBuffer.buffer,
                MotionControllerBuffer.buffer,
            ], workload: self.visibleCharacterCount
        )
        self.commands[self.phase].wait()
        MotionManager.sample(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        MotionManager.animate(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        NodeManager.transform(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        CameraManager.update(command: self.commands[self.phase])
        self.commands[self.phase].wait()
        if (self.decorationVisibility) {
            self.cameraNode.capture(command: self.commands[self.phase], color: [
                self.attachment.0.clear().store(),
            ], depth: self.attachment.1.clear().store())
        } else {
            self.debugCameraNode.capture(command: self.commands[self.phase], color: [
                self.attachment.0.clear().store(),
            ], depth: self.attachment.1.clear().store())
        }
        self.commands[self.phase].commit()
    }
}
