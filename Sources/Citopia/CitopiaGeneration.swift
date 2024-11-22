
// import the Metal graphics API
import MetalKit

// define the class extension for all the generation functions
extension Citopia {
    
    // define the function that generates the exterior map
    func generateExteriorMap(blockCount: Int, blockSideLength: Float, blockDistance: Float) {
        
        // save the arguments
        self.blockCount = blockCount
        self.blockSideLength = blockSideLength
        self.blockDistance = blockDistance
        
        // iterate through all the grid points to initialize the exterior connection data
        for x in 0...self.blockCount {
            for z in 0...self.blockCount {
                
                // store all the possible exterior connections at the current grid point
                var possibleExteriorConnections: [(String, String)] = []
                
                // if x is not 0, connect this grid point to the previous neighbor in the x direction
                if (x != 0) {
                    possibleExteriorConnections.append(
                        ("(\(x), \(z)) - (\(x - 1), \(z))", "(\(x - 1), \(z)) - (\(x), \(z))")
                    )
                }
                
                // if z is not 0, connect this grid point to the previous neighbor in the z direction
                if (z != 0) {
                    possibleExteriorConnections.append(
                        ("(\(x), \(z)) - (\(x), \(z - 1))", "(\(x), \(z - 1)) - (\(x), \(z))")
                    )
                }
                
                // conditionally break one connection
                if (!possibleExteriorConnections.isEmpty && Bool.random()) {
                    possibleExteriorConnections.remove(
                        at: Int.random(in: 0..<possibleExteriorConnections.count)
                    )
                }
                
                // store the connections
                for possibleExteriorConnection in possibleExteriorConnections {
                    self.exteriorConnectionData.insert(possibleExteriorConnection.0)
                    self.exteriorConnectionData.insert(possibleExteriorConnection.1)
                }
            }
        }
        
        // compute the origin to center all the blocks
        let blockLength = Float(self.blockCount) * self.blockSideLength
        let intervalLength = Float(self.blockCount) * self.blockDistance
        let origin = simd_float2(
            repeating: -(blockLength + intervalLength) * 0.5
        )
        
        // initialize the foundationalBuildingBlocks between blocks by checking the exterior connection data
        for x in 0...self.blockCount {
            for z in 0...self.blockCount {
                
                // break the connection along the x direction
                if (x != 0 && !self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x - 1), \(z))")) {
                    let blockPosition = simd_float2(
                        (Float(x) - 0.5) * (self.blockSideLength + self.blockDistance),
                        Float(z) * (self.blockSideLength + self.blockDistance)
                    )
                    let blockSize = simd_float3(
                        self.blockSideLength - 1.0, Float(Int.random(in: 1...5) * 3),
                        self.blockDistance
                    )
                    self.foundationalBuildingBlocks.append((
                        blockPosition + origin,
                        0.0, blockSize, 2
                    ))
                }
                
                // break the connection along the z direction
                if (z != 0 && !self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x), \(z - 1))")) {
                    let blockPosition = simd_float2(
                        Float(x) * (self.blockSideLength + self.blockDistance),
                        (Float(z) - 0.5) * (self.blockSideLength + self.blockDistance)
                    )
                    let blockSize = simd_float3(
                        self.blockDistance, Float(Int.random(in: 1...5) * 3),
                        self.blockSideLength - 1.0
                    )
                    self.foundationalBuildingBlocks.append((
                        blockPosition + origin,
                        0.0, blockSize, 2
                    ))
                }
            }
        }
        
        // initialize the map node data
        for z in 0...self.blockCount {
            for x in 0...self.blockCount {
                
                // create a new map node
                var mapNode = MapNodeData()
                mapNode.position = simd_float4(
                    Float(x) * (self.blockSideLength + self.blockDistance) + origin.x, 0.0,
                    Float(z) * (self.blockSideLength + self.blockDistance) + origin.y, 0.0
                )
                mapNode.dimension = simd_float4(
                    self.blockDistance, 0.0,
                    self.blockDistance, 0.0
                )
                var connections: [Int32] = []
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x - 1), \(z))")) {
                    connections.append(Int32(z * (self.blockCount + 1) + x - 1))
                }
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x + 1), \(z))")) {
                    connections.append(Int32(z * (self.blockCount + 1) + x + 1))
                }
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x), \(z - 1))")) {
                    connections.append(Int32((z - 1) * (self.blockCount + 1) + x))
                }
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x), \(z + 1))")) {
                    connections.append(Int32((z + 1) * (self.blockCount + 1) + x))
                }
                mapNode.data.w = Int32(connections.count)
                for (i, connection) in connections.enumerated() {
                    mapNode.connections[i] = connection
                }
                self.mapNodes.append(mapNode)
            }
        }
        
        // save the grid dimension data
        let sideCount = Int(ceil(Float(self.blockCount + 2) / 2.0))
        self.mapGridCount = sideCount * sideCount
        self.gridLengthX = 2 * (self.blockSideLength + self.blockDistance)
        self.gridLengthZ = 2 * (self.blockSideLength + self.blockDistance)
    }
    
    // define the function that generates the buildings
    func generateBuildings() {
        
        // compute the origin to center all the blocks
        let blockLength = Float(self.blockCount) * self.blockSideLength
        let intervalLength = Float(self.blockCount) * self.blockDistance
        let origin = simd_float2(
            repeating: -(blockLength + intervalLength) * 0.5
        )
        
        // initialize the buildings
        for x in 0..<self.blockCount {
            for z in 0..<self.blockCount {
                
                // define the color index of the building
                let buildingColorIndex = Int(2)
                
                // create the floors
                let blockPosition = simd_float2(
                    (Float(x) + 0.5) * (self.blockSideLength + self.blockDistance),
                    (Float(z) + 0.5) * (self.blockSideLength + self.blockDistance)
                )
                
                // create the first floor
                self.foundationalBuildingBlocks.append((
                    blockPosition + origin, 0.0,
                    simd_float3(
                        self.blockSideLength + 1.3, 0.05,
                        self.blockSideLength + 1.3
                    ), buildingColorIndex
                ))
                
                // create additional floors
                let numAdditionalFloors = Int.random(in: 1...5)
                for floor in 1...numAdditionalFloors {
                    let offset = (floor % 2 != 0) ? 0.4 : 0.0
                    self.foundationalBuildingBlocks.append((
                        blockPosition + origin, 3.0 * Float(floor),
                        simd_float3(
                            self.blockSideLength + Float(offset), 3.0,
                            self.blockSideLength + Float(offset)
                        ), buildingColorIndex
                    ))
                }
                
                // create the pillars
                var pillarOffsetX = self.blockSideLength / 2.0
                var pillarOffsetZ = self.blockSideLength / 2.0
                for corner in 0...3 {
                    self.foundationalBuildingBlocks.append((
                        blockPosition + origin + simd_float2(pillarOffsetX, pillarOffsetZ), 0.0,
                        simd_float3(
                            1.0,
                            3.0 * Float(1 + numAdditionalFloors) + 0.5,
                            1.0
                        ), buildingColorIndex
                    ))
                    if (corner % 2 == 0) {
                        pillarOffsetX *= -1.0
                    } else {
                        pillarOffsetZ *= -1.0
                    }
                }
                
                // create the rooftop
                self.foundationalBuildingBlocks.append((
                    blockPosition + origin, 3.0 * Float(1 + numAdditionalFloors),
                    simd_float3(
                        self.blockSideLength + 1.2,
                        0.5,
                        self.blockSideLength + 1.2
                    ), buildingColorIndex
                ))
                
                // define an array of the indices of the map nodes inside the building
                var mapNodeIndices: [Int] = []
                
                // create a single map node at the center of the building
                var mapNode = MapNodeData()
                mapNode.position = simd_float4(
                    blockPosition.x + origin.x, 0.0,
                    blockPosition.y + origin.y, 0.0
                )
                mapNode.dimension = simd_float4(
                    self.blockSideLength * 0.8, 0.0,
                    self.blockSideLength * 0.8, 0.0
                )
                self.mapNodes.append(mapNode)
                
                // store the index of the single map node
                mapNodeIndices.append(self.mapNodes.count - 1)
                
                // define a closure for connecting two map nodes
                let connect: (Int, Int) -> () = { a, b in
                    var count = Int(self.mapNodes[a].data.w)
                    self.mapNodes[a].connections[count] = Int32(b)
                    self.mapNodes[a].data.w = Int32(count + 1)
                    count = Int(self.mapNodes[b].data.w)
                    self.mapNodes[b].connections[count] = Int32(a)
                    self.mapNodes[b].data.w = Int32(count + 1)
                }
                
                // define an array of all the available entrance directions
                var directions: [Int] = []
                
                // create the entrances if the side is not blocked
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x + 1), \(z))")) {
                    directions.append(0)
                }
                if (self.exteriorConnectionData.contains("(\(x), \(z)) - (\(x), \(z + 1))")) {
                    directions.append(1)
                }
                if (self.exteriorConnectionData.contains("(\(x + 1), \(z)) - (\(x + 1), \(z + 1))")) {
                    directions.append(2)
                }
                if (self.exteriorConnectionData.contains("(\(x), \(z + 1)) - (\(x + 1), \(z + 1))")) {
                    directions.append(3)
                }
                
                // randomly remove some entrances
                let entranceCounts = [
                    1, 1, 1, 1, 1, 2, 2, 2, 3, 4,
                ]
                let entranceCount = entranceCounts[Int.random(in: 0...9)]
                while (directions.count > entranceCount) {
                    directions.remove(at: Int.random(
                        in: 0..<directions.count
                    ))
                }
                
                // create connections for the entrances
                if (directions.contains(0)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + length1 * 0.5,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(length1, 3.0, 0.2), buildingColorIndex
                    ))
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - length2 * 0.5,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(length2, 3.0, 0.2), buildingColorIndex
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y - self.blockSideLength * 0.5 - 1.0, 0.0
                    )
                    self.mapNodes.append(exteriorEntranceNode)
                    
                    // connect the exterior entrance node with other map nodes
                    connect(self.mapNodes.count - 1, z * (self.blockCount + 1) + x)
                    connect(self.mapNodes.count - 1, z * (self.blockCount + 1) + x + 1)
                    
                    // create the interior entrance node
                    var interiorEntranceNode = MapNodeData()
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y - self.blockSideLength * 0.5 + 1.0, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // connect the interior entrance node with the building node
                    connect(self.mapNodes.count - 1, mapNodeIndices[0])
                    
                    // create a large wall
                } else {
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(self.blockSideLength, 3.0, 0.2), buildingColorIndex
                    ))
                }
                if (directions.contains(1)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + length1 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length1), buildingColorIndex
                    ))
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - length2 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length2), buildingColorIndex
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x - self.blockSideLength * 0.5 - 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(exteriorEntranceNode)
                    
                    // connect the exterior entrance node with other map nodes
                    connect(self.mapNodes.count - 1, x + (self.blockCount + 1) * z)
                    connect(self.mapNodes.count - 1, x + (self.blockCount + 1) * (z + 1))
                    
                    // create the interior entrance node
                    var interiorEntranceNode = MapNodeData()
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x - self.blockSideLength * 0.5 + 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // connect the interior entrance node with the building node
                    connect(self.mapNodes.count - 1, mapNodeIndices[0])
                    
                    // create a large wall
                } else {
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y
                        ), 0.0, simd_float3(0.2, 3.0, self.blockSideLength), buildingColorIndex
                    ))
                }
                if (directions.contains(2)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + length1 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length1), buildingColorIndex
                    ))
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - length2 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length2), buildingColorIndex
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + self.blockSideLength * 0.5 + 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(exteriorEntranceNode)
                    
                    // connect the exterior entrance node with other map nodes
                    connect(self.mapNodes.count - 1, (x + 1) + (self.blockCount + 1) * z)
                    connect(self.mapNodes.count - 1, (x + 1) + (self.blockCount + 1) * (z + 1))
                    
                    // create the interior entrance node
                    var interiorEntranceNode = MapNodeData()
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + self.blockSideLength * 0.5 - 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // connect the interior entrance node with the building node
                    connect(self.mapNodes.count - 1, mapNodeIndices[0])
                    
                    // create a large wall
                } else {
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y
                        ), 0.0, simd_float3(0.2, 3.0, self.blockSideLength), buildingColorIndex
                    ))
                }
                if (directions.contains(3)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + length1 * 0.5,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(length1, 3.0, 0.2), buildingColorIndex
                    ))
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - length2 * 0.5,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(length2, 3.0, 0.2), buildingColorIndex
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y + self.blockSideLength * 0.5 + 1.0, 0.0
                    )
                    self.mapNodes.append(exteriorEntranceNode)
                    
                    // connect the exterior entrance node with other map nodes
                    connect(self.mapNodes.count - 1, (z + 1) * (self.blockCount + 1) + x)
                    connect(self.mapNodes.count - 1, (z + 1) * (self.blockCount + 1) + x + 1)
                    
                    // create the interior entrance node
                    var interiorEntranceNode = MapNodeData()
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y + self.blockSideLength * 0.5 - 1.0, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // connect the interior entrance node with the building node
                    connect(self.mapNodes.count - 1, mapNodeIndices[0])
                    
                    // create a large wall
                } else {
                    self.foundationalBuildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(self.blockSideLength, 3.0, 0.2), buildingColorIndex
                    ))
                }
            }
        }
    }
}
