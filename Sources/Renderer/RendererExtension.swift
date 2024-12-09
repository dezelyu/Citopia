
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
        
        // compute the speed factor
        let speed = Float(self.activeKeys.contains(" ") ? 10.0 : 1.0)
        
        // compute the directional vectors
        let forward = self.forwardNode.feedback()[3] - self.centerNode.feedback()[3]
        let left = self.leftNode.feedback()[3] - self.centerNode.feedback()[3]
        let up = self.upNode.feedback()[3] - self.centerNode.feedback()[3]
        
        // update the target position of the camera
        if (self.activeKeys.contains("w")) {
            self.targetPosition += simd_float3(forward.x, forward.y, forward.z) * speed
        }
        if (self.activeKeys.contains("s")) {
            self.targetPosition -= simd_float3(forward.x, forward.y, forward.z) * speed
        }
        if (self.activeKeys.contains("a")) {
            self.targetPosition += simd_float3(left.x, left.y, left.z) * speed
        }
        if (self.activeKeys.contains("d")) {
            self.targetPosition -= simd_float3(left.x, left.y, left.z) * speed
        }
        if (self.activeKeys.contains("e")) {
            self.targetPosition += simd_float3(up.x, up.y, up.z) * speed
        }
        if (self.activeKeys.contains("q")) {
            self.targetPosition -= simd_float3(up.x, up.y, up.z) * speed
        }
        self.targetPosition -= simd_float3(forward.x, forward.y, forward.z) * self.moveVector.z
        self.targetPosition -= simd_float3(left.x, left.y, left.z) * self.moveVector.x
        
        // limit the target position
        self.targetPosition.y = max(1.5, min(self.targetPosition.y, 100.0))
    }
    
    // define the function that updates the target rotation of the camera
    func updateTargetRotation(delta: CGVector) {
        
        // define the sensitivity
        let sensitivity = Float(0.01)
        
        // update the target rotation of the camera
        self.targetRotation.y -= Float(delta.dx) * sensitivity
        self.targetRotation.x += Float(delta.dy) * sensitivity
        self.targetRotation.x = max(
            -Float.pi * 0.4, min(self.targetRotation.x, Float.pi * 0.4)
        )
    }
    
    // define the function that updates the position of the ground
    func updateGroundPosition() {
        self.groundNode.position.x = Float(Int(self.cameraNode.position.x) / 100) * 100.0
        self.groundNode.position.z = Float(Int(self.cameraNode.position.z) / 100) * 100.0
        self.groundNode.position.y = -self.cameraNode.position.y * 0.01
    }
    
    // define the function that stores the new active key
    func start(press: String) {
        self.activeKeys.insert(press.lowercased())
        
        // show or hide the decorations when the V key is pressed
        if (press.lowercased() == "v") {
            self.decorationVisibility = !self.decorationVisibility
        }
    }
    
    // define the function that removes the new active key
    func remove(press: String) {
        self.activeKeys.remove(press.lowercased())
    }
    
    // define the function that generates the frustum planes
    func generateFrustumPlanes() -> [simd_float4] {
        let view = self.cameraNode.transform.inverse
        let projection = simd_float4x4(self.camera.projectionTransform(withViewportSize: self.size))
        let projectionView = projection * view
        var frustumPlane0 = simd_float4.zero
        var frustumPlane1 = simd_float4.zero
        var frustumPlane2 = simd_float4.zero
        var frustumPlane3 = simd_float4.zero
        var frustumPlane4 = simd_float4.zero
        var frustumPlane5 = simd_float4.zero
        frustumPlane0.x = projectionView[0].w - projectionView[0].y
        frustumPlane0.y = projectionView[1].w - projectionView[1].y
        frustumPlane0.z = projectionView[2].w - projectionView[2].y
        frustumPlane0.w = projectionView[3].w - projectionView[3].y
        frustumPlane0 = frustumPlane0 / length(simd_float3(frustumPlane0.x, frustumPlane0.y, frustumPlane0.z))
        frustumPlane1.x = projectionView[0].w + projectionView[0].y
        frustumPlane1.y = projectionView[1].w + projectionView[1].y
        frustumPlane1.z = projectionView[2].w + projectionView[2].y
        frustumPlane1.w = projectionView[3].w + projectionView[3].y
        frustumPlane1 = frustumPlane1 / length(simd_float3(frustumPlane1.x, frustumPlane1.y, frustumPlane1.z))
        frustumPlane2.x = projectionView[0].w - projectionView[0].x
        frustumPlane2.y = projectionView[1].w - projectionView[1].x
        frustumPlane2.z = projectionView[2].w - projectionView[2].x
        frustumPlane2.w = projectionView[3].w - projectionView[3].x
        frustumPlane2 = frustumPlane2 / length(simd_float3(frustumPlane2.x, frustumPlane2.y, frustumPlane2.z))
        frustumPlane3.x = projectionView[0].w + projectionView[0].x
        frustumPlane3.y = projectionView[1].w + projectionView[1].x
        frustumPlane3.z = projectionView[2].w + projectionView[2].x
        frustumPlane3.w = projectionView[3].w + projectionView[3].x
        frustumPlane3 = frustumPlane3 / length(simd_float3(frustumPlane3.x, frustumPlane3.y, frustumPlane3.z))
        frustumPlane4.x = projectionView[0].w + projectionView[0].z
        frustumPlane4.y = projectionView[1].w + projectionView[1].z
        frustumPlane4.z = projectionView[2].w + projectionView[2].z
        frustumPlane4.w = projectionView[3].w + projectionView[3].z
        frustumPlane4 = frustumPlane4 / length(simd_float3(frustumPlane4.x, frustumPlane4.y, frustumPlane4.z))
        frustumPlane5.x = projectionView[0].w - projectionView[0].z
        frustumPlane5.y = projectionView[1].w - projectionView[1].z
        frustumPlane5.z = projectionView[2].w - projectionView[2].z
        frustumPlane5.w = projectionView[3].w - projectionView[3].z
        frustumPlane5 = frustumPlane5 / length(simd_float3(frustumPlane5.x, frustumPlane5.y, frustumPlane5.z))
        return [
            frustumPlane0,
            frustumPlane1,
            frustumPlane2,
            frustumPlane3,
            frustumPlane4,
            frustumPlane5,
        ]
    }
    
    // define the function that generates the buildings
    func createBuildings(buildingBlocks: [(simd_float2, Float, simd_float3, Int, Bool)]) {
        let blockSceneAsset = SceneAsset(name: "Assets.scnassets/Elements/Block.scn")
        let blockMeshAsset = blockSceneAsset.meshes.first!
        let blockMesh = Mesh(asset: blockMeshAsset)
        for buildingBlock in buildingBlocks {
            var blockMeshNode: MeshNode!
            if (buildingBlock.4) {
                blockMeshNode = MeshNode(
                    mesh: blockMesh, category: 1
                )
            } else {
                blockMeshNode = MeshNode(
                    mesh: blockMesh, category: 2
                )
            }
            blockMeshNode.position = simd_float3(
                buildingBlock.0.x, buildingBlock.1,
                buildingBlock.0.y
            )
            blockMeshNode.scale = buildingBlock.2
            blockMeshNode.data.2 = buildingBlock.3
            NodeManager.attach(node: blockMeshNode)
            self.meshNodes.append(blockMeshNode)
        }
    }
    
    // define the function that generates the furnitures
    func createFurnitures(furnitureBlocks: [(simd_float2, Float, simd_float3, Int)]) {
        let blockSceneAsset = SceneAsset(name: "Assets.scnassets/Elements/Block.scn")
        let blockMeshAsset = blockSceneAsset.meshes.first!
        let blockMesh = Mesh(
            asset: blockMeshAsset, scale: 1.0,
            range: (0.0, 0.0, 100.0, 100.0)
        )
        for furnitureBlock in furnitureBlocks {
            let blockMeshNode = MeshNode(
                mesh: blockMesh, category: 1
            )
            blockMeshNode.position = simd_float3(
                furnitureBlock.0.x, furnitureBlock.1,
                furnitureBlock.0.y
            )
            blockMeshNode.scale = furnitureBlock.2
            blockMeshNode.data.2 = furnitureBlock.3
            NodeManager.attach(node: blockMeshNode)
            self.meshNodes.append(blockMeshNode)
        }
    }
}
