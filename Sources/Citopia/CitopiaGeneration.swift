
// import the Metal graphics API
import MetalKit

// define the class extension for all the generation functions
extension Citopia {
    
    // define the function that generates the exterior map
    func generateExteriorMap() {
        
        // iterate through all the grid points to initialize the exterior connection data
        for x in 0...self.blockCount {
            for z in 0...self.blockCount {
                
                // store all the possible exterior connections at the current grid point
                var possibleExteriorConnections: [(simd_int4, simd_int4)] = []
                
                // if x is not 0, connect this grid point to the previous neighbor in the x direction
                if (x != 0) {
                    possibleExteriorConnections.append((
                        simd_int4(Int32(x), Int32(z), Int32(x - 1), Int32(z)),
                        simd_int4(Int32(x - 1), Int32(z), Int32(x), Int32(z))
                    ))
                }
                
                // if z is not 0, connect this grid point to the previous neighbor in the z direction
                if (z != 0) {
                    possibleExteriorConnections.append((
                        simd_int4(Int32(x), Int32(z), Int32(x), Int32(z - 1)),
                        simd_int4(Int32(x), Int32(z - 1), Int32(x), Int32(z))
                    ))
                }
                
                // conditionally break one connection
                if (0 < x && x < self.blockCount && 0 < z && z < self.blockCount) {
                    if (!possibleExteriorConnections.isEmpty && Bool.random()) {
                        possibleExteriorConnections.remove(
                            at: Int.random(in: 0..<possibleExteriorConnections.count)
                        )
                    }
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
        
        // initialize the buildingBlocks between blocks by checking the exterior connection data
        for x in 0...self.blockCount {
            for z in 0...self.blockCount {
                
                // break the connection along the x direction
                if (x != 0 && !self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x - 1), Int32(z)))) {
                    let blockPosition = simd_float2(
                        (Float(x) - 0.5) * (self.blockSideLength + self.blockDistance),
                        Float(z) * (self.blockSideLength + self.blockDistance)
                    )
                    let blockSize = simd_float3(
                        self.blockSideLength - 1.0, Float(Int.random(in: 2...5) * 3),
                        self.blockDistance
                    )
                    self.buildingBlocks.append((
                        blockPosition + origin, -0.2, blockSize, 2, true
                    ))
                    
                    // create the rooftop building
                    let shouldCreateRooftopBuilding = Int.random(in: 0...4)
                    let rooftopBuildingSideLengthX = Float.random(in: Float(blockSize.x / 5.0)...Float(blockSize.x / 3.0))
                    let rooftopBuildingSideLengthZ = Float.random(in: Float(blockSize.z / 5.0)...Float(blockSize.z / 3.0))
                    let rooftopBuldingOffset = simd_float2(Float.random(in: -3.0...3.0), Float.random(in: -3.0...3.0))
                    if (shouldCreateRooftopBuilding == 1) {
                        self.buildingBlocks.append((
                            blockPosition + origin + rooftopBuldingOffset, blockSize.y + 0.5,
                            simd_float3(rooftopBuildingSideLengthX, 2, rooftopBuildingSideLengthZ),
                            2, false
                        ))
                        self.buildingBlocks.append((
                            blockPosition + origin + rooftopBuldingOffset, blockSize.y + 2.5,
                            simd_float3(rooftopBuildingSideLengthX + 0.5, 0.5, rooftopBuildingSideLengthZ + 0.5),
                            2, false
                        ))
                    }
                }
                
                // break the connection along the z direction
                if (z != 0 && !self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x), Int32(z - 1)))) {
                    let blockPosition = simd_float2(
                        Float(x) * (self.blockSideLength + self.blockDistance),
                        (Float(z) - 0.5) * (self.blockSideLength + self.blockDistance)
                    )
                    let blockSize = simd_float3(
                        self.blockDistance, Float(Int.random(in: 1...5) * 3),
                        self.blockSideLength - 1.0
                    )
                    self.buildingBlocks.append((
                        blockPosition + origin, -0.2, blockSize, 2, true
                    ))
                    
                    // create the rooftop building
                    let shouldCreateRooftopBuilding = Int.random(in: 0...4)
                    let rooftopBuildingSideLengthX = Float.random(in: Float(blockSize.x / 5.0)...Float(blockSize.x / 3.0))
                    let rooftopBuildingSideLengthZ = Float.random(in: Float(blockSize.z / 5.0)...Float(blockSize.z / 3.0))
                    let rooftopBuldingOffset = simd_float2(Float.random(in: -3.0...3.0), Float.random(in: -3.0...3.0))
                    if (shouldCreateRooftopBuilding == 1) {
                        self.buildingBlocks.append((
                            blockPosition + origin + rooftopBuldingOffset, blockSize.y + 0.5,
                            simd_float3(rooftopBuildingSideLengthX, 2, rooftopBuildingSideLengthZ),
                            2, false
                        ))
                        self.buildingBlocks.append((
                            blockPosition + origin + rooftopBuldingOffset, blockSize.y + 2.5,
                            simd_float3(rooftopBuildingSideLengthX + 0.5, 0.5, rooftopBuildingSideLengthZ + 0.5),
                            2, false
                        ))
                    }
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
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x - 1), Int32(z)))) {
                    connections.append(Int32(z * (self.blockCount + 1) + x - 1))
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x + 1), Int32(z)))) {
                    connections.append(Int32(z * (self.blockCount + 1) + x + 1))
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x), Int32(z - 1)))) {
                    connections.append(Int32((z - 1) * (self.blockCount + 1) + x))
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x), Int32(z + 1)))) {
                    connections.append(Int32((z + 1) * (self.blockCount + 1) + x))
                }
                mapNode.data.w = Int32(connections.count)
                for (i, connection) in connections.enumerated() {
                    mapNode.connections[i] = connection
                }
                self.mapNodes.append(mapNode)
            }
        }
    }
    
    // define the function that generates the building decorations
    func generateBuildingDecorations(x: Int, z: Int, buildingColorIndex: Int) {
        
        // compute the origin to center all the blocks
        let blockLength = Float(self.blockCount) * self.blockSideLength
        let intervalLength = Float(self.blockCount) * self.blockDistance
        let origin = simd_float2(
            repeating: -(blockLength + intervalLength) * 0.5
        )
        
        // define the block position
        let blockPosition = simd_float2(
            (Float(x) + 0.5) * (self.blockSideLength + self.blockDistance),
            (Float(z) + 0.5) * (self.blockSideLength + self.blockDistance)
        )
        
        // create the first floor
        self.buildingBlocks.append((
            blockPosition + origin, 0.0,
            simd_float3(
                self.blockSideLength + 1.3, 0.02,
                self.blockSideLength + 1.3
            ), buildingColorIndex, true
        ))
        
        // create additional floors
        var numAdditionalFloors = Int.random(in: (-2)...2)
        numAdditionalFloors += Int.random(in: 1...4) * Int.random(in: 1...4)
        numAdditionalFloors = max(1, numAdditionalFloors)
        for floor in 1...numAdditionalFloors {
            let offset = (floor % 2 != 0) ? 0.4 : 0.0
            self.buildingBlocks.append((
                blockPosition + origin, 3.0 * Float(floor),
                simd_float3(
                    self.blockSideLength + Float(offset), 3.0,
                    self.blockSideLength + Float(offset)
                ), buildingColorIndex, false
            ))
        }
        
        // create the pillars
        var pillarOffsetX = self.blockSideLength / 2.0
        var pillarOffsetZ = self.blockSideLength / 2.0
        for corner in 0...3 {
            self.buildingBlocks.append((
                blockPosition + origin + simd_float2(pillarOffsetX, pillarOffsetZ), 0.0,
                simd_float3(1.0, 3.0 * Float(1 + numAdditionalFloors) + 0.5, 1.0),
                buildingColorIndex, false
            ))
            if (corner % 2 == 0) {
                pillarOffsetX *= -1.0
            } else {
                pillarOffsetZ *= -1.0
            }
        }
        
        // create the rooftop
        self.buildingBlocks.append((
            blockPosition + origin, 3.0 * Float(1 + numAdditionalFloors),
            simd_float3(
                self.blockSideLength + 1.2, 0.6,
                self.blockSideLength + 1.2
            ), buildingColorIndex, false
        ))
        
        // create the rooftop building
        let shouldCreateRooftopBuilding = Int.random(in: 0...4)
        let rooftopBuildingSideLengthX = Float.random(in: Float(self.blockSideLength / 5.0)...Float(self.blockSideLength / 3.0))
        let rooftopBuildingSideLengthZ = Float.random(in: Float(self.blockSideLength / 5.0)...Float(self.blockSideLength / 3.0))
        let rooftopBuldingOffset = simd_float2(Float.random(in: -3.0...3.0), Float.random(in: -3.0...3.0))
        if (shouldCreateRooftopBuilding == 1) {
            self.buildingBlocks.append((
                blockPosition + origin + rooftopBuldingOffset, 3.0 * Float(1 + numAdditionalFloors) + 0.5,
                simd_float3(rooftopBuildingSideLengthX, 2.5, rooftopBuildingSideLengthZ),
                buildingColorIndex, false
            ))
            self.buildingBlocks.append((
                blockPosition + origin + rooftopBuldingOffset, 3.0 * Float(1 + numAdditionalFloors) + 3.0,
                simd_float3(rooftopBuildingSideLengthX + 0.5, 0.5, rooftopBuildingSideLengthZ + 0.5),
                buildingColorIndex, false
            ))
        }
        
        // define an array of all the available entrance directions
        var billboardDirections: [Int] = []
        
        // create the entrances if the side is not blocked
        if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x + 1), Int32(z)))) {
            billboardDirections.append(0)
        }
        if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x), Int32(z + 1)))) {
            billboardDirections.append(1)
        }
        if (self.exteriorConnectionData.contains(simd_int4(Int32(x + 1), Int32(z), Int32(x + 1), Int32(z + 1)))) {
            billboardDirections.append(2)
        }
        if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z + 1), Int32(x + 1), Int32(z + 1)))) {
            billboardDirections.append(3)
        }
        
        // create the top billboards and billboards on buildings
        if (!billboardDirections.isEmpty) {
            for billboardDirection in billboardDirections {
                let billboardLength = Float.random(in: 5.0...10.0)
                var billboardPositionOffset = Float.random(in: 1...2)
                let billboardPositionOffsetDirection = Int.random(in: 0...1)
                billboardPositionOffset = billboardPositionOffsetDirection == 0 ? billboardPositionOffset : -billboardPositionOffset
                if (billboardDirection == 0) {
                    let shouldCreateBillboard = Int.random(in: 0...4)
                    if (shouldCreateBillboard == 1) {
                        self.buildingBlocks.append((
                            simd_float2(
                                blockPosition.x + origin.x + billboardPositionOffset,
                                blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                            ),
                            3.0 * Float(1 + numAdditionalFloors) + 0.6,
                            simd_float3(billboardLength, 3.0, 0.2),
                            Int.random(in: 3...22), false
                        ))
                    }
                    var floor = numAdditionalFloors
                    while (floor > 1) {
                        let shouldCreateSideBillboard = Int.random(in: 1...3)
                        let upperLimit = Float(floor == 1 ? 2.5 : 5.5)
                        let billboardScale = simd_float2(Float.random(in: 2.0...8.0), Float.random(in: 2.0...upperLimit))
                        let offsetRange = (self.blockSideLength - billboardScale.x) * 0.4
                        let positionOffset = Float.random(in: (-offsetRange)...offsetRange)
                        if (shouldCreateSideBillboard == 1) {
                            self.buildingBlocks.append((
                                simd_float2(
                                    blockPosition.x + origin.x + positionOffset,
                                    blockPosition.y + origin.y - self.blockSideLength * 0.5 - 0.4
                                ),
                                3.0 * Float(floor) - billboardScale.y / 2.0 + Float.random(in: -0.2...0.2),
                                simd_float3(billboardScale.x, billboardScale.y, 0.15),
                                Int.random(in: 3...22), false
                            ))
                            floor -= 2
                        } else {
                            floor -= 1
                        }
                    }
                } else if (billboardDirection == 1) {
                    let shouldCreateBillboard = Int.random(in: 0...4)
                    if (shouldCreateBillboard == 1) {
                        self.buildingBlocks.append((
                            simd_float2(
                                blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                                blockPosition.y + origin.y + billboardPositionOffset
                            ),
                            3.0 * Float(1 + numAdditionalFloors) + 0.6,
                            simd_float3(0.2, 3.0, billboardLength),
                            Int.random(in: 3...22), false
                        ))
                    }
                    var floor = numAdditionalFloors
                    while (floor > 1) {
                        let shouldCreateSideBillboard = Int.random(in: 1...3)
                        let upperLimit = Float(floor == 1 ? 2.5 : 5.0)
                        let billboardScale = simd_float2(Float.random(in: 2.0...8.0), Float.random(in: 2.0...upperLimit))
                        let offsetRange = (self.blockSideLength - billboardScale.x) * 0.4
                        let positionOffset = Float.random(in: (-offsetRange)...offsetRange)
                        if (shouldCreateSideBillboard == 1) {
                            self.buildingBlocks.append((
                                simd_float2(
                                    blockPosition.x + origin.x - self.blockSideLength * 0.5 - 0.4,
                                    blockPosition.y + origin.y + positionOffset
                                ),
                                3.0 * Float(floor) - billboardScale.y / 2.0 + Float.random(in: -0.2...0.2),
                                simd_float3(0.15, billboardScale.y, billboardScale.x),
                                Int.random(in: 3...22), false
                            ))
                            floor -= 2
                        } else {
                            floor -= 1
                        }
                    }
                } else if (billboardDirection == 2) {
                    let shouldCreateBillboard = Int.random(in: 0...4)
                    if (shouldCreateBillboard == 1) {
                        self.buildingBlocks.append((
                            simd_float2(
                                blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                                blockPosition.y + origin.y + billboardPositionOffset
                            ),
                            3.0 * Float(1 + numAdditionalFloors) + 0.6,
                            simd_float3(0.2, 3.0, billboardLength),
                            Int.random(in: 3...22), false
                        ))
                    }
                    var floor = numAdditionalFloors
                    while (floor > 1) {
                        let shouldCreateSideBillboard = Int.random(in: 1...3)
                        let upperLimit = Float(floor == 1 ? 2.5 : 5.0)
                        let billboardScale = simd_float2(Float.random(in: 2.0...8.0), Float.random(in: 2.0...upperLimit))
                        let offsetRange = (self.blockSideLength - billboardScale.x) * 0.4
                        let positionOffset = Float.random(in: (-offsetRange)...offsetRange)
                        if (shouldCreateSideBillboard == 1) {
                            self.buildingBlocks.append((
                                simd_float2(
                                    blockPosition.x + origin.x + self.blockSideLength * 0.5 + 0.4,
                                    blockPosition.y + origin.y + positionOffset
                                ),
                                3.0 * Float(floor) - billboardScale.y / 2.0 + Float.random(in: -0.2...0.2),
                                simd_float3(0.15, billboardScale.y, billboardScale.x),
                                Int.random(in: 3...22), false
                            ))
                            floor -= 2
                        } else {
                            floor -= 1
                        }
                    }
                } else if (billboardDirection == 3) {
                    let shouldCreateBillboard = Int.random(in: 0...4)
                    if (shouldCreateBillboard == 1) {
                        self.buildingBlocks.append((
                            simd_float2(
                                blockPosition.x + origin.x + billboardPositionOffset,
                                blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                            ),
                            3.0 * Float(1 + numAdditionalFloors) + 0.6,
                            simd_float3(billboardLength, 3.0, 0.2),
                            Int.random(in: 3...22), false
                        ))
                    }
                    var floor = numAdditionalFloors
                    while (floor > 1) {
                        let shouldCreateSideBillboard = Int.random(in: 1...3)
                        let upperLimit = Float(floor == 1 ? 2.5 : 5.0)
                        let billboardScale = simd_float2(Float.random(in: 2.0...8.0), Float.random(in: 2.0...upperLimit))
                        let offsetRange = (self.blockSideLength - billboardScale.x) * 0.4
                        let positionOffset = Float.random(in: (-offsetRange)...offsetRange)
                        if (shouldCreateSideBillboard == 1) {
                            self.buildingBlocks.append((
                                simd_float2(
                                    blockPosition.x + origin.x + positionOffset,
                                    blockPosition.y + origin.y + self.blockSideLength * 0.5 + 0.4
                                ),
                                3.0 * Float(floor) - billboardScale.y / 2.0 + Float.random(in: -0.2...0.2),
                                simd_float3(billboardScale.x, billboardScale.y, 0.15),
                                Int.random(in: 3...22), false
                            ))
                            floor -= 2
                        } else {
                            floor -= 1
                        }
                    }
                }
            }
            
            // create the side billboards
            if (numAdditionalFloors > 1 && billboardDirections.contains(0) && billboardDirections.contains(1)) {
                let sideBillboardLengthLeft = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let sideBillboardLengthRight = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let shouldCreateSideBillboardLeft = Int.random(in: 0...3)
                let shouldCreateSideBillboardRight = Int.random(in: 0...3)
                if (shouldCreateSideBillboardLeft == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - pillarOffsetX - 1.0,
                            blockPosition.y + origin.y - pillarOffsetZ
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthLeft,
                        simd_float3(2.0, sideBillboardLengthLeft, 0.2),
                        Int.random(in: 3...22), false
                    ))
                }
                if (shouldCreateSideBillboardRight == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - pillarOffsetX,
                            blockPosition.y + origin.y - pillarOffsetZ - 1.0
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthRight,
                        simd_float3(0.2, sideBillboardLengthRight, 2.0),
                        Int.random(in: 3...22), false
                    ))
                }
            }
            if (numAdditionalFloors > 1 && billboardDirections.contains(1) && billboardDirections.contains(3)) {
                let sideBillboardLengthLeft = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let sideBillboardLengthRight = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let shouldCreateSideBillboardLeft = Int.random(in: 0...3)
                let shouldCreateSideBillboardRight = Int.random(in: 0...3)
                if (shouldCreateSideBillboardLeft == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - pillarOffsetX - 1.0,
                            blockPosition.y + origin.y + pillarOffsetZ
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthLeft,
                        simd_float3(2.0, sideBillboardLengthLeft, 0.2),
                        Int.random(in: 3...22), false
                    ))
                }
                if (shouldCreateSideBillboardRight == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - pillarOffsetX,
                            blockPosition.y + origin.y + pillarOffsetZ + 1.0
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthRight,
                        simd_float3(0.2, sideBillboardLengthRight, 2.0),
                        Int.random(in: 3...22), false
                    ))
                }
            }
            if (numAdditionalFloors > 1 && billboardDirections.contains(3) && billboardDirections.contains(2)) {
                let sideBillboardLengthLeft = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let sideBillboardLengthRight = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let shouldCreateSideBillboardLeft = Int.random(in: 0...3)
                let shouldCreateSideBillboardRight = Int.random(in: 0...3)
                if (shouldCreateSideBillboardLeft == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + pillarOffsetX + 1.0,
                            blockPosition.y + origin.y + pillarOffsetZ
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthLeft,
                        simd_float3(2.0, sideBillboardLengthLeft, 0.2),
                        Int.random(in: 3...22), false
                    ))
                }
                if (shouldCreateSideBillboardRight == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + pillarOffsetX,
                            blockPosition.y + origin.y + pillarOffsetZ + 1.0
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthRight,
                        simd_float3(0.2, sideBillboardLengthRight, 2.0),
                        Int.random(in: 3...22), false
                    ))
                }
            }
            if (numAdditionalFloors > 1 && billboardDirections.contains(0) && billboardDirections.contains(2)) {
                let sideBillboardLengthLeft = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let sideBillboardLengthRight = Float.random(in: 3.0...Float(numAdditionalFloors * 2))
                let shouldCreateSideBillboardLeft = Int.random(in: 0...3)
                let shouldCreateSideBillboardRight = Int.random(in: 0...3)
                if (shouldCreateSideBillboardLeft == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + pillarOffsetX + 1.0,
                            blockPosition.y + origin.y - pillarOffsetZ
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthLeft,
                        simd_float3(2.0, sideBillboardLengthLeft, 0.2),
                        Int.random(in: 3...22), false
                    ))
                }
                if (shouldCreateSideBillboardRight == 1) {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + pillarOffsetX,
                            blockPosition.y + origin.y - pillarOffsetZ - 1.0
                        ),
                        3.0 * Float(numAdditionalFloors + 1) - 0.5 - sideBillboardLengthRight,
                        simd_float3(0.2, sideBillboardLengthRight, 2.0),
                        Int.random(in: 3...22), false
                    ))
                }
            }
        }
    }
    
    // define the function that generates the buildings
    func generateBuildings() {
        
        // compute the origin to center all the blocks
        let blockLength = Float(self.blockCount) * self.blockSideLength
        let intervalLength = Float(self.blockCount) * self.blockDistance
        let origin = simd_float2(
            repeating: -(blockLength + intervalLength) * 0.5
        )
        
        // register all the valid building indices
        var buildingIndices: Set<simd_int2> = []
        for x in 0..<self.blockCount {
            for z in 0..<self.blockCount {
                buildingIndices.insert(simd_int2(Int32(x), Int32(z)))
            }
        }
        
        // initialize the apartments
        var apartmentIndices: Set<simd_int2> = []
        let apartmentBedCount = Int(self.blockSideLength / 2.5) * Int(self.blockSideLength / 3.5)
        let apartmentCount = self.characterCount / apartmentBedCount + 1
        while (buildingIndices.count > 0 && apartmentIndices.count < apartmentCount) {
            let randomBuildingIndex = buildingIndices.randomElement()!
            buildingIndices.remove(randomBuildingIndex)
            apartmentIndices.insert(randomBuildingIndex)
        }
        
        // initialize the office buildings
        var officeIndices: Set<simd_int2> = []
        let deskLength = self.blockSideLength - 6.0
        let numDesksX = Int(self.blockSideLength / 4.5)
        let numChairsZ = Int(deskLength / 1.5)
        let officeDeskCount = Int(numDesksX) * Int(numChairsZ * 2)
        let officeCount = (apartmentBedCount * apartmentCount) / officeDeskCount + 1
        while (buildingIndices.count > 0 && officeIndices.count < officeCount) {
            let randomBuildingIndex = buildingIndices.randomElement()!
            buildingIndices.remove(randomBuildingIndex)
            officeIndices.insert(randomBuildingIndex)
        }
        
        // define the number of recreation building types
        let recreationBuildingTypeCount = Int(3)
        let recreationBuildingCountPerType = buildingIndices.count / recreationBuildingTypeCount
        
        // initialize the gyms
        var gymIndices: Set<simd_int2> = []
        while (buildingIndices.count > 0 && gymIndices.count < recreationBuildingCountPerType) {
            let randomBuildingIndex = buildingIndices.randomElement()!
            buildingIndices.remove(randomBuildingIndex)
            gymIndices.insert(randomBuildingIndex)
        }
        
        // initialize the restaurants
        var restaurantIndices: Set<simd_int2> = []
        while (buildingIndices.count > 0 && restaurantIndices.count < recreationBuildingCountPerType) {
            let randomBuildingIndex = buildingIndices.randomElement()!
            buildingIndices.remove(randomBuildingIndex)
            restaurantIndices.insert(randomBuildingIndex)
        }
        
        // initialize the libraries
        var libraryIndices: Set<simd_int2> = []
        while (buildingIndices.count > 0 && libraryIndices.count < recreationBuildingCountPerType) {
            let randomBuildingIndex = buildingIndices.randomElement()!
            buildingIndices.remove(randomBuildingIndex)
            libraryIndices.insert(randomBuildingIndex)
        }
        
        // initialize the buildings
        for x in 0..<self.blockCount {
            for z in 0..<self.blockCount {
                
                // define the block position
                let blockPosition = simd_float2(
                    (Float(x) + 0.5) * (self.blockSideLength + self.blockDistance),
                    (Float(z) + 0.5) * (self.blockSideLength + self.blockDistance)
                )
                
                // create a new building
                var building = BuildingData()
                building.position = simd_float4(
                    blockPosition.x + origin.x, 0.0,
                    blockPosition.y + origin.y, 0.0
                )
                
                // define the color index of the building
                var buildingColorIndex = Int(2)
                
                // initialize the building corresponding to its type
                if (apartmentIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    building.data.x = 1
                    buildingColorIndex = Int.random(in: 23...28)
                } else if (officeIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    building.data.x = 2
                    buildingColorIndex = Int.random(in: 35...40)
                } else if (gymIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    building.data.x = 3
                    buildingColorIndex = Int.random(in: 43...47)
                } else if (restaurantIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    building.data.x = 4
                    buildingColorIndex = 0
                } else if (libraryIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    building.data.x = 5
                    buildingColorIndex = Int.random(in: 51...53)
                }
                
                // generate the building decorations
                self.generateBuildingDecorations(
                    x: x, z: z, buildingColorIndex: buildingColorIndex
                )
                
                // define an array of the indices of the interior entrance nodes
                var interiorEntranceNodeIndices: [Int] = []
                
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
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x + 1), Int32(z)))) {
                    directions.append(0)
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z), Int32(x), Int32(z + 1)))) {
                    directions.append(1)
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x + 1), Int32(z), Int32(x + 1), Int32(z + 1)))) {
                    directions.append(2)
                }
                if (self.exteriorConnectionData.contains(simd_int4(Int32(x), Int32(z + 1), Int32(x + 1), Int32(z + 1)))) {
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
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + length1 * 0.5,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(length1, 3.0, 0.2), buildingColorIndex, true
                    ))
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - length2 * 0.5,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(length2, 3.0, 0.2), buildingColorIndex, true
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.data.x = 1
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
                    interiorEntranceNode.data.x = 2
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y - self.blockSideLength * 0.5 + 1.0, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // store the index of the interior entrance node
                    interiorEntranceNodeIndices.append(self.mapNodes.count - 1)
                    
                    // update the building data
                    building.externalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 2)
                    building.internalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 1)
                    building.data.w += 1
                } else {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + 0.1
                        ), 0.0, simd_float3(self.blockSideLength, 3.0, 0.2), buildingColorIndex, true
                    ))
                }
                if (directions.contains(1)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + length1 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length1), buildingColorIndex, true
                    ))
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - length2 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length2), buildingColorIndex, true
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.data.x = 1
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
                    interiorEntranceNode.data.x = 2
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x - self.blockSideLength * 0.5 + 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // store the index of the interior entrance node
                    interiorEntranceNodeIndices.append(self.mapNodes.count - 1)
                    
                    // update the building data
                    building.externalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 2)
                    building.internalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 1)
                    building.data.w += 1
                } else {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + 0.1,
                            blockPosition.y + origin.y
                        ), 0.0, simd_float3(0.2, 3.0, self.blockSideLength), buildingColorIndex, true
                    ))
                }
                if (directions.contains(2)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y - self.blockSideLength * 0.5 + length1 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length1), buildingColorIndex, true
                    ))
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - length2 * 0.5
                        ), 0.0, simd_float3(0.2, 3.0, length2), buildingColorIndex, true
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.data.x = 1
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
                    interiorEntranceNode.data.x = 2
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + self.blockSideLength * 0.5 - 1.0, 0.0,
                        blockPosition.y + origin.y + offset, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // store the index of the interior entrance node
                    interiorEntranceNodeIndices.append(self.mapNodes.count - 1)
                    
                    // update the building data
                    building.externalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 2)
                    building.internalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 1)
                    building.data.w += 1
                } else {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - 0.1,
                            blockPosition.y + origin.y
                        ), 0.0, simd_float3(0.2, 3.0, self.blockSideLength), buildingColorIndex, true
                    ))
                }
                if (directions.contains(3)) {
                    
                    // compute the position offset of the entrance
                    let offset = Float.random(in: (-0.3)...0.3) * self.blockSideLength
                    
                    // create two walls
                    let length1 = self.blockSideLength * 0.5 + offset - 1.0
                    let length2 = self.blockSideLength * 0.5 - offset - 1.0
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x - self.blockSideLength * 0.5 + length1 * 0.5,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(length1, 3.0, 0.2), buildingColorIndex, true
                    ))
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x + self.blockSideLength * 0.5 - length2 * 0.5,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(length2, 3.0, 0.2), buildingColorIndex, true
                    ))
                    
                    // create the exterior entrance node
                    var exteriorEntranceNode = MapNodeData()
                    exteriorEntranceNode.data.x = 1
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
                    interiorEntranceNode.data.x = 2
                    interiorEntranceNode.position = simd_float4(
                        blockPosition.x + origin.x + offset, 0.0,
                        blockPosition.y + origin.y + self.blockSideLength * 0.5 - 1.0, 0.0
                    )
                    self.mapNodes.append(interiorEntranceNode)
                    
                    // connect the interior entrance node with the exterior entrance node
                    connect(self.mapNodes.count - 1, self.mapNodes.count - 2)
                    
                    // store the index of the interior entrance node
                    interiorEntranceNodeIndices.append(self.mapNodes.count - 1)
                    
                    // update the building data
                    building.externalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 2)
                    building.internalEntrances[Int(building.data.w)] = Int32(self.mapNodes.count - 1)
                    building.data.w += 1
                } else {
                    self.buildingBlocks.append((
                        simd_float2(
                            blockPosition.x + origin.x,
                            blockPosition.y + origin.y + self.blockSideLength * 0.5 - 0.1
                        ), 0.0, simd_float3(self.blockSideLength, 3.0, 0.2), buildingColorIndex, true
                    ))
                }
                
                // initialize the building as an apartment building
                if (apartmentIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    self.initializeApartmentBuildingInterior(
                        index: self.buildings.count, origin: origin, blockPosition: blockPosition,
                        interiorEntranceNodeIndices: interiorEntranceNodeIndices,
                        connect: connect
                    )
                }
                
                // initialize the building as an office building
                if (officeIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    self.initializeOfficeBuildingInterior(
                        index: self.buildings.count, origin: origin, blockPosition: blockPosition,
                        interiorEntranceNodeIndices: interiorEntranceNodeIndices,
                        connect: connect
                    )
                }
                
                // initialize the building as a gym building
                if (gymIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    self.initializeGymBuildingInterior(
                        index: self.buildings.count, origin: origin, blockPosition: blockPosition,
                        interiorEntranceNodeIndices: interiorEntranceNodeIndices,
                        building: &building,
                        connect: connect
                    )
                }
                
                // initialize the building as a restaurant building
                if (restaurantIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    self.initializeRestaurantBuildingInterior(
                        index: self.buildings.count, origin: origin, blockPosition: blockPosition,
                        interiorEntranceNodeIndices: interiorEntranceNodeIndices,
                        building: &building,
                        connect: connect
                    )
                }
                
                // initialize the building as a library building
                if (libraryIndices.contains(simd_int2(Int32(x), Int32(z)))) {
                    self.initializeLibraryBuildingInterior(
                        index: self.buildings.count, origin: origin, blockPosition: blockPosition,
                        interiorEntranceNodeIndices: interiorEntranceNodeIndices,
                        building: &building,
                        connect: connect
                    )
                }
                
                // store the new building
                self.buildings.append(building)
            }
        }
    }
    
    // define the function that initializes the apartment building interior
    func initializeApartmentBuildingInterior(index: Int,
                                             origin: simd_float2,
                                             blockPosition: simd_float2,
                                             interiorEntranceNodeIndices: [Int],
                                             connect: (Int, Int) -> ()) {
        
        // create the beds
        let numBedsX = Int(self.blockSideLength / 2.5)
        let numBedsZ = Int(self.blockSideLength / 3.5)
        let distanceBetweenBedsX = self.blockSideLength / Float(numBedsX + 1)
        let distanceBetweenBedsZ = self.blockSideLength / Float(numBedsZ + 1)
        for bedX in 1...numBedsX {
            for bedZ in 1...numBedsZ {
                let offsetX = distanceBetweenBedsX * Float(bedX)
                let offsetZ = distanceBetweenBedsZ * Float(bedZ)
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ), 0.05,
                    simd_float3(1.0, 0.2, 2.0), Int.random(in: 29...33)
                ))
                
                // create the pillow
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ - 0.75), 0.25,
                    simd_float3(0.5, 0.05, 0.25), 34
                ))
            }
        }
        
        // create an array storing the node position and index
        var nodePositionIndexArray: [(simd_float4, Int)] = []
        
        // create a map node for each space between beds
        let nodeOffset = simd_float2((distanceBetweenBedsX) / 2.0, (distanceBetweenBedsZ) / 2.0)
        for bedZ in 0...numBedsZ {
            for bedX in 0...numBedsX {
                let offsetX = distanceBetweenBedsX * Float(bedX)
                let offsetZ = distanceBetweenBedsZ * Float(bedZ)
                let nodePosition = blockPosition + origin + nodeOffset - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ)
                var mapNode = MapNodeData()
                mapNode.data.x = 3
                mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                self.mapNodes.append(mapNode)
                nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
            }
        }
        for bedZ in 0...numBedsZ {
            for bedX in 0...numBedsX {
                let nodeIndexInArray = bedX + bedZ * (numBedsX + 1)
                let nodeIndex = nodePositionIndexArray[nodeIndexInArray].1
                if (bedX > 0) {
                    connect(nodeIndex, nodePositionIndexArray[(bedX - 1) + bedZ * (numBedsX + 1)].1)
                }
                if (bedZ > 0) {
                    connect(nodeIndex, nodePositionIndexArray[bedX + (bedZ - 1) * (numBedsX + 1)].1)
                }
                if (bedX > 0 && bedZ > 0) {
                    
                    // create a map node for bed
                    var mapNode = MapNodeData()
                    mapNode.data.x = 4
                    mapNode.position += self.mapNodes[nodeIndex].position
                    mapNode.position += self.mapNodes[nodePositionIndexArray[(bedX - 1) + bedZ * (numBedsX + 1)].1].position
                    mapNode.position /= 2.0
                    self.mapNodes.append(mapNode)
                    
                    // connect the bed node with the left and right node
                    connect(self.mapNodes.count - 1, nodeIndex)
                    connect(self.mapNodes.count - 1, nodePositionIndexArray[(bedX - 1) + bedZ * (numBedsX + 1)].1)
                    
                    // store the bed data
                    if (self.bedData[index] == nil) {
                        self.bedData[index] = []
                    }
                    self.bedData[index]!.insert(simd_int4(
                        Int32(index), Int32(self.mapNodes.count - 1), -1, 0
                    ))
                }
            }
        }
        
        // connect the map node with the interior entrance nodes
        for interiorEntranceNodeIndex in interiorEntranceNodeIndices {
            let position = self.mapNodes[interiorEntranceNodeIndex].position
            let array = nodePositionIndexArray.sorted {
                distance(position, $0.0) < distance(position, $1.0)
            }
            connect(interiorEntranceNodeIndex, array[0].1)
            connect(interiorEntranceNodeIndex, array[1].1)
        }
    }
    
    // define the function that initializes the office building interior
    func initializeOfficeBuildingInterior(index: Int,
                                          origin: simd_float2,
                                          blockPosition: simd_float2,
                                          interiorEntranceNodeIndices: [Int],
                                          connect: (Int, Int) -> ()) {
        
        // create the desks
        let deskHeight = Float(0.6)
        let deskLength = self.blockSideLength - 6.0
        let numDesksX = Int(self.blockSideLength / 4.5)
        let numChairsZ = Int(deskLength / 1.5)
        let distanceBetweenDesksX = self.blockSideLength / Float(numDesksX + 1)
        let distanceBetweenChairsZ = deskLength / Float(numChairsZ + 1)
        var previousLaptopColor = Int(-1)
        for deskX in 1...numDesksX {
            let offsetX = distanceBetweenDesksX * Float(deskX)
            self.furnitureBlocks.append((
                blockPosition + origin - simd_float2(self.blockSideLength / 2.0, 0.0) + simd_float2(offsetX, 0), 0.05,
                simd_float3(1.0, deskHeight, deskLength), 41
            ))
            for chairZ in 1...numChairsZ {
                
                // create the chairs
                let offsetZ = distanceBetweenChairsZ * Float(chairZ)
                let nodePositionPos = blockPosition + origin + simd_float2(
                    offsetX + 0.8 - self.blockSideLength / 2.0,
                    offsetZ - deskLength / 2.0
                )
                self.furnitureBlocks.append((
                    nodePositionPos, 0.05,
                    simd_float3(0.4, 0.4, 0.4), 42
                ))
                let nodePositionNeg = blockPosition + origin + simd_float2(
                    offsetX - 0.8 - self.blockSideLength / 2.0,
                    offsetZ - deskLength / 2.0
                )
                self.furnitureBlocks.append((
                    nodePositionNeg, 0.05,
                    simd_float3(0.4, 0.4, 0.4), 42
                ))
                
                // create a laptop
                var laptopColorArray = [Int]()
                for i in 0...4 {
                    if (i != previousLaptopColor) {
                        laptopColorArray.append(i)
                    }
                }
                let laptopColorIndex = laptopColorArray.randomElement()!
                previousLaptopColor = laptopColorIndex
                let laptopColor = 3 + laptopColorIndex * 4 + Int.random(in: 0...3)
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(self.blockSideLength / 2.0, deskLength / 2.0) + simd_float2(offsetX, offsetZ), deskHeight + 0.05,
                    simd_float3(0.8, 0.1, 0.8), laptopColor
                ))
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(self.blockSideLength / 2.0, deskLength / 2.0) + simd_float2(offsetX, offsetZ), deskHeight + 0.15,
                    simd_float3(0.1, 0.45, 0.8), laptopColor
                ))
            }
        }
        
        // create an array storing the desk node position and index
        var nodePositionIndexArray: [(simd_float4, Int)] = []
        let nodeOffset = simd_float2((distanceBetweenDesksX) / 2.0, (distanceBetweenChairsZ) / 2.0)
        for chairZ in -1...(numChairsZ + 1) {
            for deskX in 0...numDesksX {
                let offsetX = distanceBetweenDesksX * Float(deskX)
                let offsetZ = distanceBetweenChairsZ * Float(chairZ)
                let nodePosition = blockPosition + origin + nodeOffset - simd_float2(self.blockSideLength / 2.0, deskLength / 2.0) + simd_float2(offsetX, offsetZ)
                var mapNode = MapNodeData()
                mapNode.data.x = 3
                mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                self.mapNodes.append(mapNode)
                nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
            }
        }
        
        // create the charis
        for chairZ in 0...(numChairsZ + 2) {
            for deskX in 0...numDesksX {
                let nodeIndexInArray = deskX + chairZ * (numDesksX + 1)
                let nodeIndex = nodePositionIndexArray[nodeIndexInArray].1
                if (deskX > 0 && (chairZ == 0 || chairZ == numChairsZ + 2)) {
                    connect(nodeIndex, nodePositionIndexArray[(deskX - 1) + chairZ * (numDesksX + 1)].1)
                }
                
                // create the chair nodes
                if (chairZ > 0) {
                    connect(nodeIndex, nodePositionIndexArray[deskX + (chairZ - 1) * (numDesksX + 1)].1)
                    if (chairZ > 1 && chairZ < numChairsZ + 2) {
                        let offset = distanceBetweenDesksX * 0.5 - 0.8
                        if (deskX != numDesksX) {
                            
                            // create the chair node
                            let nodeIndexInArray = deskX + chairZ * (numDesksX + 1)
                            let nodeIndex = nodePositionIndexArray[nodeIndexInArray].1
                            let nodePosition = simd_float2(
                                self.mapNodes[nodeIndex].position.x + offset,
                                self.mapNodes[nodeIndex].position.z
                            )
                            var mapNode = MapNodeData()
                            mapNode.data.x = 5
                            mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                            self.mapNodes.append(mapNode)
                            
                            // connect the desk node to the chair node
                            connect(nodeIndex, self.mapNodes.count - 1)
                            
                            // store the chair data
                            if (self.officeData[index] == nil) {
                                self.officeData[index] = []
                            }
                            self.officeData[index]!.insert(simd_int4(
                                Int32(index), Int32(self.mapNodes.count - 1), 0, 0
                            ))
                        }
                        if (deskX != 0) {
                            
                            // create the chair node
                            let nodeIndexInArray = deskX + (chairZ - 1) * (numDesksX + 1)
                            let nodeIndex = nodePositionIndexArray[nodeIndexInArray].1
                            let nodePosition = simd_float2(
                                self.mapNodes[nodeIndex].position.x - offset,
                                self.mapNodes[nodeIndex].position.z
                            )
                            var mapNode = MapNodeData()
                            mapNode.data.x = 5
                            mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                            self.mapNodes.append(mapNode)
                            
                            // connect the desk node to the chair node
                            connect(nodeIndex, self.mapNodes.count - 1)
                            
                            // store the chair data
                            if (self.officeData[index] == nil) {
                                self.officeData[index] = []
                            }
                            self.officeData[index]!.insert(simd_int4(
                                Int32(index), Int32(self.mapNodes.count - 1), 2, 0
                            ))
                        }
                    }
                }
            }
        }
        
        // connect the closest desk nodes with the interior entrance nodes
        for interiorEntranceNodeIndex in interiorEntranceNodeIndices {
            let position = self.mapNodes[interiorEntranceNodeIndex].position
            let array = nodePositionIndexArray.sorted {
                distance(position, $0.0) < distance(position, $1.0)
            }
            connect(interiorEntranceNodeIndex, array[0].1)
            connect(interiorEntranceNodeIndex, array[1].1)
        }
    }
    
    // define the function that initializes the gym building interior
    func initializeGymBuildingInterior(index: Int,
                                       origin: simd_float2,
                                       blockPosition: simd_float2,
                                       interiorEntranceNodeIndices: [Int],
                                       building: inout BuildingData,
                                       connect: (Int, Int) -> ()) {
        
        // create the treadmills
        let numTreadmillsX = Int(self.blockSideLength / 3.5)
        let numTreadmillsZ = Int(self.blockSideLength / 4.5)
        let distanceBetweenTreadmillsX = self.blockSideLength / Float(numTreadmillsX + 1)
        let distanceBetweenTreadmillsZ = self.blockSideLength / Float(numTreadmillsZ + 1)
        for treadmillZ in 1...numTreadmillsZ {
            for treadmillX in 1...numTreadmillsX {
                let offsetX = distanceBetweenTreadmillsX * Float(treadmillX)
                let offsetZ = distanceBetweenTreadmillsZ * Float(treadmillZ)
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ), 0.0,
                    simd_float3(1.0, 0.2, 2.0), 48
                ))
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ + 1.05), 0.0,
                    simd_float3(0.2, 1.2, 0.1), 49
                ))
                self.furnitureBlocks.append((
                    blockPosition + origin - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ + 1.0), 1.2,
                    simd_float3(0.6, 0.1, 0.3), 50
                ))
            }
        }
        
        // create an array storing the node position and index
        var nodePositionIndexArray: [(simd_float4, Int)] = []
        
        // create a map node for each space between treadmills
        let nodeOffset = simd_float2((distanceBetweenTreadmillsX) / 2.0, (distanceBetweenTreadmillsZ) / 2.0)
        for treadmillZ in 0...numTreadmillsZ {
            for treadmillX in 0...numTreadmillsX {
                let offsetX = distanceBetweenTreadmillsX * Float(treadmillX)
                let offsetZ = distanceBetweenTreadmillsZ * Float(treadmillZ)
                let nodePosition = blockPosition + origin + nodeOffset - simd_float2(repeating: self.blockSideLength / 2.0) + simd_float2(offsetX, offsetZ)
                var mapNode = MapNodeData()
                mapNode.data.x = 3
                mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                self.mapNodes.append(mapNode)
                nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
            }
        }
        var interactableNodes: [Int32] = []
        for treadmillZ in 0...numTreadmillsZ {
            for treadmillX in 0...numTreadmillsX {
                let nodeIndexInArray = treadmillX + treadmillZ * (numTreadmillsX + 1)
                let nodeIndex = nodePositionIndexArray[nodeIndexInArray].1
                if (treadmillX > 0) {
                    let targetNodeIndex = nodePositionIndexArray[(treadmillX - 1) + treadmillZ * (numTreadmillsX + 1)].1
                    connect(nodeIndex, targetNodeIndex)
                }
                if (treadmillZ > 0) {
                    let targetNodeIndex = nodePositionIndexArray[treadmillX + (treadmillZ - 1) * (numTreadmillsX + 1)].1
                    connect(nodeIndex, targetNodeIndex)
                }
                if (treadmillX > 0 && treadmillZ < numTreadmillsZ) {
                    
                    // create a map node for treadmill
                    let targetNodeIndex = nodePositionIndexArray[(treadmillX - 1) + treadmillZ * (numTreadmillsX + 1)].1
                    var mapNode = MapNodeData()
                    mapNode.data.x = 6
                    mapNode.data.y = 1
                    mapNode.position += self.mapNodes[nodeIndex].position
                    mapNode.position += self.mapNodes[targetNodeIndex].position
                    mapNode.position /= 2.0
                    mapNode.position.z += 0.5
                    self.mapNodes.append(mapNode)
                    if (interactableNodes.count < 16) {
                        interactableNodes.append(Int32(self.mapNodes.count - 1))
                    }
                    
                    // connect the bed node with the left and right node
                    connect(self.mapNodes.count - 1, nodeIndex)
                    connect(self.mapNodes.count - 1, targetNodeIndex)
                }
            }
        }
        building.data.z = Int32(interactableNodes.count)
        for (i, interactableNode) in interactableNodes.enumerated() {
            building.interactableNodes[i] = interactableNode
        }
        
        // connect the closest desk nodes with the interior entrance nodes
        for interiorEntranceNodeIndex in interiorEntranceNodeIndices {
            let position = self.mapNodes[interiorEntranceNodeIndex].position
            let array = nodePositionIndexArray.sorted {
                distance(position, $0.0) < distance(position, $1.0)
            }
            connect(interiorEntranceNodeIndex, array[0].1)
            connect(interiorEntranceNodeIndex, array[1].1)
        }
    }
    
    // define the function that initializes the restaurant building interior
    func initializeRestaurantBuildingInterior(index: Int,
                                              origin: simd_float2,
                                              blockPosition: simd_float2,
                                              interiorEntranceNodeIndices: [Int],
                                              building: inout BuildingData,
                                              connect: (Int, Int) -> ()) {
        
        // create the chef's table
        let tablePosition = blockPosition + origin + simd_float2(0, 2.2)
        self.furnitureBlocks.append((
            tablePosition + simd_float2(-0.6, 0), 0.05,
            simd_float3(0.5, 0.8, 1.0), 48
        ))
        self.furnitureBlocks.append((
            tablePosition + simd_float2(0.6, 0), 0.05,
            simd_float3(0.5, 0.8, 1.0), 48
        ))
        self.furnitureBlocks.append((
            tablePosition, 0.85,
            simd_float3(1.8, 0.2, 1.0), 48
        ))
        self.furnitureBlocks.append((
            tablePosition, 1.05,
            simd_float3(0.5, 0.02, 0.3), 34
        ))
        self.furnitureBlocks.append((
            tablePosition, 0.05,
            simd_float3(0.5, 0.5, 0.5), 57
        ))
        
        // create the chef's bed
        let bedPosition = blockPosition + origin + simd_float2(0, -1.8)
        self.furnitureBlocks.append((
            bedPosition, 0.05,
            simd_float3(1.0, 0.2, 2.0), Int.random(in: 29...33)
        ))
        
        // create the chef's pillow
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(0, -2.55), 0.25,
            simd_float3(0.5, 0.05, 0.25), 34
        ))
        
        // create the map node for chef's working table
        var mapNode = MapNodeData()
        mapNode.data.x = 5
        mapNode.position = simd_float4(tablePosition.x, 0, tablePosition.y - 1.0, 0.0)
        self.mapNodes.append(mapNode)
        
        // create the map node for chef's bed
        mapNode = MapNodeData()
        mapNode.data.x = 4
        mapNode.position = simd_float4(bedPosition.x, 0, bedPosition.y + 1.5, 0.0)
        self.mapNodes.append(mapNode)
        self.serviceIndustryWorkersData.append((
            simd_int4(Int32(index), Int32(mapNodes.count - 1), -1, 0),
            simd_int4(Int32(index), Int32(mapNodes.count - 2), 1, 0)
        ))
        
        // create the map node for transition
        mapNode = MapNodeData()
        mapNode.data.x = 3
        mapNode.position = (self.mapNodes[mapNodes.count - 1].position + self.mapNodes[mapNodes.count - 2].position) / 2.0
        self.mapNodes.append(mapNode)
        
        connect(mapNodes.count - 1, mapNodes.count - 2)
        connect(mapNodes.count - 1, mapNodes.count - 3)
        
        // create the restaurant desks
        let deskWidth = self.blockSideLength * 0.4
        let deskHeight = Float(1.5)
        let deskOffset = (deskWidth + deskHeight) / 2.0
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(0, deskOffset), 0.05,
            simd_float3(deskWidth, 1.0, deskHeight), 34
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(0, -deskOffset), 0.05,
            simd_float3(deskWidth, 1.0, deskHeight), 34
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(deskOffset, 0), 0.05,
            simd_float3(deskHeight, 1.0, deskWidth), 34
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(-deskOffset, 0), 0.05,
            simd_float3(deskHeight, 1.0, deskWidth), 34
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(deskOffset, deskOffset), 0.05,
            simd_float3(deskHeight, 1.0, deskHeight), 48
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(deskOffset, -deskOffset), 0.05,
            simd_float3(deskHeight, 1.0, deskHeight), 48
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(-deskOffset, deskOffset), 0.05,
            simd_float3(deskHeight, 1.0, deskHeight), 48
        ))
        self.furnitureBlocks.append((
            blockPosition + origin + simd_float2(-deskOffset, -deskOffset), 0.05,
            simd_float3(deskHeight, 1.0, deskHeight), 48
        ))
        
        // create an array storing the desk node position and index
        var nodePositionIndexArray: [(simd_float4, Int)] = []
        
        // create the chairs
        let numChairs = Int(deskWidth / 1.5)
        let chairOffset = deskWidth / (Float(numChairs + 1))
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(0, deskOffset)
            chairPosition -= simd_float2(deskWidth * 0.5, 0)
            chairPosition += simd_float2(Float(numChair) * chairOffset, deskHeight)
            self.furnitureBlocks.append((
                chairPosition, 0.05,
                simd_float3(0.4, 0.4, 0.4), 34
            ))
            
            // create the plate
            var platePosition = blockPosition + origin + simd_float2(0, deskOffset)
            platePosition -= simd_float2(deskWidth * 0.5, 0)
            platePosition += simd_float2(Float(numChair) * chairOffset, 0)
            self.furnitureBlocks.append((
                platePosition, 1.05,
                simd_float3(0.4, 0.02, 0.4), 48
            ))
        }
        var edgePosition = blockPosition + origin + simd_float2(-(2.0 * deskHeight + 0.5 * deskWidth), 2.0 * deskHeight + 0.5 * deskWidth)
        mapNode = MapNodeData()
        mapNode.data.x = 3
        mapNode.position = simd_float4(edgePosition.x, 0.0, edgePosition.y, 0.0)
        self.mapNodes.append(mapNode)
        nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(0, deskOffset)
            chairPosition -= simd_float2(deskWidth * 0.5, 0)
            chairPosition += simd_float2(Float(numChair) * chairOffset, deskHeight)
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(chairPosition.x - 0.5 * chairOffset, 0.0, chairPosition.y + 0.5 * deskHeight, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        }
        
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(0, -deskOffset)
            chairPosition -= simd_float2(deskWidth * 0.5, 0)
            chairPosition += simd_float2(Float(numChair) * chairOffset, -deskHeight)
            self.furnitureBlocks.append((
                chairPosition, 0.05,
                simd_float3(0.4, 0.4, 0.4), 34
            ))
            
            // create the plate
            var platePosition = blockPosition + origin + simd_float2(0, -deskOffset)
            platePosition -= simd_float2(deskWidth * 0.5, 0)
            platePosition += simd_float2(Float(numChair) * chairOffset, 0)
            self.furnitureBlocks.append((
                platePosition, 1.05,
                simd_float3(0.4, 0.02, 0.4), 48
            ))
        }
        edgePosition = blockPosition + origin + simd_float2(2.0 * deskHeight + 0.5 * deskWidth, 2.0 * deskHeight + 0.5 * deskWidth)
        mapNode = MapNodeData()
        mapNode.data.x = 3
        mapNode.position = simd_float4(edgePosition.x, 0.0, edgePosition.y, 0.0)
        self.mapNodes.append(mapNode)
        nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(deskOffset, 0)
            chairPosition -= simd_float2(0, deskWidth * 0.5)
            chairPosition += simd_float2(deskHeight, Float(numChairs - numChair + 1) * chairOffset)
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(chairPosition.x + 0.5 * chairOffset, 0.0, chairPosition.y + 0.5 * deskHeight, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        }
        
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(deskOffset, 0)
            chairPosition -= simd_float2(0, deskWidth * 0.5)
            chairPosition += simd_float2(deskHeight, Float(numChair) * chairOffset)
            self.furnitureBlocks.append((
                chairPosition, 0.05,
                simd_float3(0.4, 0.4, 0.4), 34
            ))
            
            // create the plate
            var platePosition = blockPosition + origin + simd_float2(deskOffset, 0)
            platePosition -= simd_float2(0, deskWidth * 0.5)
            platePosition += simd_float2(0, Float(numChair) * chairOffset)
            self.furnitureBlocks.append((
                platePosition, 1.05,
                simd_float3(0.4, 0.02, 0.4), 48
            ))
        }
        edgePosition = blockPosition + origin + simd_float2(2.0 * deskHeight + 0.5 * deskWidth, -(2.0 * deskHeight + 0.5 * deskWidth))
        mapNode = MapNodeData()
        mapNode.data.x = 3
        mapNode.position = simd_float4(edgePosition.x, 0.0, edgePosition.y, 0.0)
        self.mapNodes.append(mapNode)
        nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(0, -deskOffset)
            chairPosition -= simd_float2(deskWidth * 0.5, 0)
            chairPosition += simd_float2(Float(numChairs - numChair + 1) * chairOffset, -deskHeight)
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(chairPosition.x + 0.5 * chairOffset, 0.0, chairPosition.y - 0.5 * deskHeight, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        }
        
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(-deskOffset, 0)
            chairPosition -= simd_float2(0, deskWidth * 0.5)
            chairPosition += simd_float2(-deskHeight, Float(numChair) * chairOffset)
            self.furnitureBlocks.append((
                chairPosition, 0.05,
                simd_float3(0.4, 0.4, 0.4), 34
            ))
            
            // create the plate
            var platePosition = blockPosition + origin + simd_float2(-deskOffset, 0)
            platePosition -= simd_float2(0, deskWidth * 0.5)
            platePosition += simd_float2(0, Float(numChair) * chairOffset)
            self.furnitureBlocks.append((
                platePosition, 1.05,
                simd_float3(0.4, 0.02, 0.4), 48
            ))
        }
        edgePosition = blockPosition + origin + simd_float2(-(2.0 * deskHeight + 0.5 * deskWidth), -(2.0 * deskHeight + 0.5 * deskWidth))
        mapNode = MapNodeData()
        mapNode.data.x = 3
        mapNode.position = simd_float4(edgePosition.x, 0.0, edgePosition.y, 0.0)
        self.mapNodes.append(mapNode)
        nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        for numChair in 1...numChairs {
            var chairPosition =  blockPosition + origin + simd_float2(-deskOffset, 0)
            chairPosition -= simd_float2(0, deskWidth * 0.5)
            chairPosition += simd_float2(-deskHeight, Float(numChair) * chairOffset)
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(chairPosition.x - 0.5 * chairOffset, 0.0, chairPosition.y - 0.5 * deskHeight, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
        }
        
        let rowCount = (numChairs + 1)
        let nodeOffset = 0.75 * deskHeight
        var nodePosition = simd_float2(repeating: 0)
        var interactableNodes: [Int32] = []
        for i in 0..<nodePositionIndexArray.count {
            if (i == 0) {
                connect(nodePositionIndexArray[i].1, nodePositionIndexArray[nodePositionIndexArray.count - 1].1)
            } else {
                connect(nodePositionIndexArray[i].1, nodePositionIndexArray[i - 1].1)
            }
            if (i % rowCount != 0) {
                
                if (i / rowCount == 0) {
                    nodePosition = simd_float2(nodePositionIndexArray[i].0.x, nodePositionIndexArray[i].0.z - nodeOffset)
                    mapNode.data.y = 3
                } else if (i / rowCount == 1) {
                    nodePosition = simd_float2(nodePositionIndexArray[i].0.x - nodeOffset, nodePositionIndexArray[i].0.z)
                    mapNode.data.y = 2
                } else if (i / rowCount == 2) {
                    nodePosition = simd_float2(nodePositionIndexArray[i].0.x, nodePositionIndexArray[i].0.z + nodeOffset)
                    mapNode.data.y = 1
                } else if (i / rowCount == 3) {
                    nodePosition = simd_float2(nodePositionIndexArray[i].0.x + nodeOffset, nodePositionIndexArray[i].0.z)
                    mapNode.data.y = 4
                }
                mapNode.data.x = 6
                mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
                self.mapNodes.append(mapNode)
                connect(nodePositionIndexArray[i].1, mapNodes.count - 1)
                if (interactableNodes.count < 16) {
                    interactableNodes.append(Int32(self.mapNodes.count - 1))
                }
            }
        }
        building.data.z = Int32(interactableNodes.count)
        for (i, interactableNode) in interactableNodes.enumerated() {
            building.interactableNodes[i] = interactableNode
        }
        
        // connect the closest desk nodes with the interior entrance nodes
        for interiorEntranceNodeIndex in interiorEntranceNodeIndices {
            let position = self.mapNodes[interiorEntranceNodeIndex].position
            let array = nodePositionIndexArray.sorted {
                distance(position, $0.0) < distance(position, $1.0)
            }
            connect(interiorEntranceNodeIndex, array[0].1)
        }
    }
    
    // define the function that initializes the library building interior
    func initializeLibraryBuildingInterior(index: Int,
                                       origin: simd_float2,
                                       blockPosition: simd_float2,
                                       interiorEntranceNodeIndices: [Int],
                                       building: inout BuildingData,
                                       connect: (Int, Int) -> ()) {
        func getBoxCorners(corner1: simd_float2, corner2: simd_float2) -> (b: simd_float2, t: simd_float2) {
            let bottomLeft = simd_float2(min(corner1.x, corner2.x), min(corner1.y, corner2.y))
            let topRight = simd_float2(max(corner1.x, corner2.x), max(corner1.y, corner2.y))
            
            return (bottomLeft, topRight)
        }
        
        // create an array storing the node position and index
        var nodePositionIndexArray: [(simd_float4, Int)] = []
        let mapNodeOffset = simd_float3(0.9, 0.6, 0.3)
        let libraryPosition = blockPosition + origin
        let (bottomLeft, topRight) = getBoxCorners(
            corner1: libraryPosition - self.blockSideLength * 0.5,
            corner2: libraryPosition + self.blockSideLength * 0.5
        )
        let bookshelfThickness = Float(0.5)
        let distanceBetweenBookshelves = Float(2.5)
        let bookshelfPadding = Float(2.0)

        // add long bookshelves
        let longBookshelfDimensions = simd_float3(
            bookshelfThickness,
            3.0,
            self.blockSideLength * 0.8
        )
        let numberOfLongBookshelvesPerSide = 2
        for i in 0..<numberOfLongBookshelvesPerSide {
            let positionLeft = simd_float2(bottomLeft.x + bookshelfPadding + Float(i) * distanceBetweenBookshelves, libraryPosition.y)
            let positionRight = simd_float2(topRight.x - bookshelfPadding - Float(i) * distanceBetweenBookshelves, libraryPosition.y)
            self.furnitureBlocks.append((positionLeft, 0.0, longBookshelfDimensions, 54))
            self.furnitureBlocks.append((positionRight, 0.0, longBookshelfDimensions, 54))
        }
        
        // add short bookshelves
        let shortBookshelfLength = self.blockSideLength - bookshelfPadding - 2.0 * Float(numberOfLongBookshelvesPerSide) * distanceBetweenBookshelves
        let shortBookshelfDimensions = simd_float3(
            shortBookshelfLength,
            3.0,
            bookshelfThickness
        )
        let numberOfShortBookshelvesPerSide = 2
        for i in 0..<numberOfShortBookshelvesPerSide {
            let position = simd_float2(libraryPosition.x, topRight.y - bookshelfPadding - Float(i) * distanceBetweenBookshelves)
            self.furnitureBlocks.append((position, 0.0, shortBookshelfDimensions, 54))
        }
        
        // add desk
        let deskDimensions = simd_float3(
            self.blockSideLength * 0.15,
            0.8,
            self.blockSideLength * 0.3
        )
        let deskPosition = simd_float2(
            libraryPosition.x,
            libraryPosition.y - Float(numberOfShortBookshelvesPerSide - 1) * distanceBetweenBookshelves
        )
        self.furnitureBlocks.append((deskPosition, 0.0, deskDimensions, 55))
        
        // add seats
        let seatDimensions = simd_float3(0.3, 0.5, 0.3)
        let (deskBottomLeft, deskTopRight) = getBoxCorners(
            corner1: deskPosition - simd_float2(deskDimensions.x, deskDimensions.z) / 2.0,
            corner2: deskPosition + simd_float2(deskDimensions.x, deskDimensions.z) / 2.0
        )
        let seatDistanceFromDesk = Float(0.3)
        let numberOfSeatsPerSideX = 3
        let distanceBetweenSeatsX = deskDimensions.x / Float(numberOfSeatsPerSideX + 1)
        var seatMapNodeIndices: [Int] = []
        for i in 0..<numberOfSeatsPerSideX {
            let xCoordinate = deskBottomLeft.x + Float(i + 1) * distanceBetweenSeatsX
            let positionTop = simd_float2(xCoordinate, deskTopRight.y + seatDistanceFromDesk)
            let positionBottom = simd_float2(xCoordinate, deskBottomLeft.y - seatDistanceFromDesk)
            self.furnitureBlocks.append((positionTop, 0.0, seatDimensions, 56))
            self.furnitureBlocks.append((positionBottom, 0.0, seatDimensions, 56))
            
            // put nodes in between seats horizontally
            var mapNodeTop = MapNodeData()
            mapNodeTop.data.x = 6
            mapNodeTop.data.y = 3
            mapNodeTop.position = simd_float4(
                positionTop.x + mapNodeOffset.z,
                0.0,
                positionTop.y,
                0.0
            )
            self.mapNodes.append(mapNodeTop)
            seatMapNodeIndices.append(self.mapNodes.count - 1)
            
            var mapNodeBottom = MapNodeData()
            mapNodeBottom.data.x = 6
            mapNodeBottom.data.y = 1
            mapNodeBottom.position = simd_float4(
                positionBottom.x - mapNodeOffset.z,
                0.0,
                positionBottom.y,
                0.0
            )
            self.mapNodes.append(mapNodeBottom)
            seatMapNodeIndices.append(self.mapNodes.count - 1)
        }

        let numberOfSeatsPerSideZ = 5
        let distanceBetweenSeatsZ = deskDimensions.z / Float(numberOfSeatsPerSideZ + 1)
        for i in 0..<numberOfSeatsPerSideZ {
            let zCoordinate = deskBottomLeft.y + Float(i + 1) * distanceBetweenSeatsZ
            let positionLeft = simd_float2(deskBottomLeft.x - seatDistanceFromDesk, zCoordinate)
            let positionRight = simd_float2(deskTopRight.x + seatDistanceFromDesk, zCoordinate)
            self.furnitureBlocks.append((positionLeft, 0.0, seatDimensions, 56))
            self.furnitureBlocks.append((positionRight, 0.0, seatDimensions, 56))
            
            // put nodes in between seats vertically
            var mapNodeLeft = MapNodeData()
            mapNodeLeft.data.x = 6
            mapNodeLeft.data.y = 0
            mapNodeLeft.position = simd_float4(
                positionLeft.x,
                0.0,
                positionLeft.y + mapNodeOffset.z,
                0.0
            )
            self.mapNodes.append(mapNodeLeft)
            seatMapNodeIndices.append(self.mapNodes.count - 1)
            
            var mapNodeRight = MapNodeData()
            mapNodeRight.data.x = 6
            mapNodeRight.data.y = 2
            mapNodeRight.position = simd_float4(
                positionRight.x,
                0.0,
                positionRight.y - mapNodeOffset.z,
                0.0
            )
            self.mapNodes.append(mapNodeRight)
            seatMapNodeIndices.append(self.mapNodes.count - 1)
        }
        
        // put a node at each corner
        let mapNodeCornerPositions = [
            
            // bottom left
            bottomLeft + mapNodeOffset.x,
            
            // top left
            simd_float2(
                bottomLeft.x + mapNodeOffset.x,
                topRight.y - mapNodeOffset.x
            ),
            
            // bottom right
            simd_float2(
                topRight.x - mapNodeOffset.x,
                bottomLeft.y + mapNodeOffset.x
            ),
            
            // top right
            topRight - mapNodeOffset.x,
        ]
        var mapNodeCornerIndices: [Int] = []
        let numberOfMapNodesOutsideLongBookshelves = 4
        let disanceOutsideMapNodesLongBookshelves = (mapNodeCornerPositions[1].y - mapNodeCornerPositions[0].y) / Float(numberOfMapNodesOutsideLongBookshelves + 1)
        for i in 0..<mapNodeCornerPositions.count {
            let nodePosition = mapNodeCornerPositions[i]
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
            mapNodeCornerIndices.append(self.mapNodes.count - 1)
            
            if (i % 2 == 0) {
                for j in 0..<numberOfMapNodesOutsideLongBookshelves {
                    let middleNodePositionZ = nodePosition.y + Float(j + 1) * disanceOutsideMapNodesLongBookshelves
                    var middleNode = MapNodeData()
                    middleNode.data.x = 3
                    middleNode.position = simd_float4(nodePosition.x, 0.0, middleNodePositionZ, 0.0)
                    self.mapNodes.append(middleNode)
                    nodePositionIndexArray.append((middleNode.position, self.mapNodes.count - 1))

                    connect(self.mapNodes.count - 2, self.mapNodes.count - 1)
                }
            }
            else {
                connect(self.mapNodes.count - 2, self.mapNodes.count - 1)
            }
        }
        
        var interactableNodesAtBookshelves: [Int32] = []

        // put nodes in between long bookshelves
        let mapNodeLeftLongBookshelfPositionX0 = bottomLeft.x + bookshelfPadding + distanceBetweenBookshelves - bookshelfThickness * 0.5 - mapNodeOffset.x
        let mapNodeLeftLongBookshelfPositionX1 = bottomLeft.x + bookshelfPadding + distanceBetweenBookshelves + bookshelfThickness * 0.5 + mapNodeOffset.x
        let mapNodeRightLongBookshelfPositionX0 = topRight.x - bookshelfPadding - distanceBetweenBookshelves + bookshelfThickness * 0.5 + mapNodeOffset.x
        let mapNodeRightLongBookshelfPositionX1 = topRight.x - bookshelfPadding - distanceBetweenBookshelves - bookshelfThickness * 0.5 - mapNodeOffset.x
        let topY = topRight.y - mapNodeOffset.x
        let bottomY = bottomLeft.y + mapNodeOffset.x
        let mapNodeLongBookshelfPositions = [
            
            // left side
            simd_float2(mapNodeLeftLongBookshelfPositionX0, bottomY),
            simd_float2(mapNodeLeftLongBookshelfPositionX0, topY),
            simd_float2(mapNodeLeftLongBookshelfPositionX1, bottomY),
            simd_float2(mapNodeLeftLongBookshelfPositionX1, topY),
            
            // right side
            simd_float2(mapNodeRightLongBookshelfPositionX0, bottomY),
            simd_float2(mapNodeRightLongBookshelfPositionX0, topY),
            simd_float2(mapNodeRightLongBookshelfPositionX1, bottomY),
            simd_float2(mapNodeRightLongBookshelfPositionX1, topY)
        ]
        var mapNodeLongBookshelfIndices: [Int] = []
        let numberOfMapNodesBetweenLongBookshelves = 5
        let disanceBetweenMapNodesLongBookshelves = (topY - bottomY) / Float(numberOfMapNodesBetweenLongBookshelves + 1)
        for i in 0..<mapNodeLongBookshelfPositions.count {
            let nodePosition = mapNodeLongBookshelfPositions[i]
            var mapNode = MapNodeData()
            mapNode.data.x = 3
            mapNode.position = simd_float4(nodePosition.x, 0.0, nodePosition.y, 0.0)
            self.mapNodes.append(mapNode)
            nodePositionIndexArray.append((mapNode.position, self.mapNodes.count - 1))
            mapNodeLongBookshelfIndices.append(self.mapNodes.count - 1)
            
            if i % 2 == 0 {
                let isLeft = i < mapNodeLongBookshelfPositions.count / 2
                for j in 0..<numberOfMapNodesBetweenLongBookshelves {
                    let walkMapNodeCoordinateZ = nodePosition.y + Float(j + 1) * disanceBetweenMapNodesLongBookshelves
                    var walkMapNode = MapNodeData()
                    walkMapNode.data.x = 3
                    walkMapNode.position = simd_float4(
                        nodePosition.x,
                        0.0,
                        walkMapNodeCoordinateZ,
                        0.0
                    )
                    self.mapNodes.append(walkMapNode)
                    
                    if (j == 0) {
                        connect(self.mapNodes.count - 2, self.mapNodes.count - 1)
                    }
                    else {
                        connect(self.mapNodes.count - 3, self.mapNodes.count - 1)
                    }

                    var bookshelfMapNode = MapNodeData()
                    bookshelfMapNode.data.x = 6
                    bookshelfMapNode.data.y = isLeft ? 2 : 0
                    bookshelfMapNode.position = simd_float4(
                        isLeft ?
                            nodePosition.x - mapNodeOffset.y
                            : nodePosition.x + mapNodeOffset.y,
                        0.0,
                        walkMapNodeCoordinateZ,
                        0.0
                    )
                    self.mapNodes.append(bookshelfMapNode)
                    interactableNodesAtBookshelves.append(Int32(self.mapNodes.count - 1))
                    
                    connect(self.mapNodes.count - 2, self.mapNodes.count - 1)
                }
            }
            else {
                connect(self.mapNodes.count - 3, self.mapNodes.count - 1)
            }
        }
        connect(mapNodeLongBookshelfIndices[0], mapNodeCornerIndices[0])
        connect(mapNodeLongBookshelfIndices[1], mapNodeCornerIndices[1])
        connect(mapNodeLongBookshelfIndices[mapNodeLongBookshelfIndices.count / 2], mapNodeCornerIndices[2])
        connect(mapNodeLongBookshelfIndices[mapNodeLongBookshelfIndices.count / 2 + 1], mapNodeCornerIndices[3])
        connect(mapNodeLongBookshelfIndices[0], mapNodeLongBookshelfIndices[2])
        connect(mapNodeLongBookshelfIndices[1], mapNodeLongBookshelfIndices[3])
        connect(mapNodeLongBookshelfIndices[2], mapNodeLongBookshelfIndices[6])
        connect(mapNodeLongBookshelfIndices[3], mapNodeLongBookshelfIndices[7])
        connect(mapNodeLongBookshelfIndices[6], mapNodeLongBookshelfIndices[4])
        connect(mapNodeLongBookshelfIndices[7], mapNodeLongBookshelfIndices[5])
        
        // put nodes in between short bookshelves
        var mapNodeShortBookshelfIndices: [Int] = []
        let numberOfMapNodesBetweenShortBookshelves = 2
        let disanceBetweenMapNodesShortBookshelves = shortBookshelfLength / Float(numberOfMapNodesBetweenShortBookshelves + 1)
        for j in 0..<numberOfShortBookshelvesPerSide {
            for i in 0..<numberOfMapNodesBetweenShortBookshelves {
                var walkMapNode = MapNodeData()
                walkMapNode.data.x = 3
                let walkMapNodePositionX = libraryPosition.x - shortBookshelfLength * 0.5 + Float(i + 1) * disanceBetweenMapNodesShortBookshelves
                let walkMapNodePositionZ = topRight.y - bookshelfPadding - mapNodeOffset.x - Float(j) * distanceBetweenBookshelves
                walkMapNode.position = simd_float4(
                    walkMapNodePositionX,
                    0.0,
                    walkMapNodePositionZ,
                    0.0
                )
                self.mapNodes.append(walkMapNode)
                mapNodeShortBookshelfIndices.append(self.mapNodes.count - 1)
                
                if (i > 0) {
                    connect(self.mapNodes.count - 3, self.mapNodes.count - 1)
                }
                
                var bookshelfMapNode = MapNodeData()
                bookshelfMapNode.data.x = 6
                bookshelfMapNode.data.y = 1
                bookshelfMapNode.position = simd_float4(
                    walkMapNodePositionX,
                    0.0,
                    walkMapNodePositionZ + mapNodeOffset.z,
                    0.0
                )
                self.mapNodes.append(bookshelfMapNode)
                interactableNodesAtBookshelves.append(Int32(self.mapNodes.count - 1))
                
                connect(self.mapNodes.count - 2, self.mapNodes.count - 1)
            }
        }
        connect(mapNodeShortBookshelfIndices[0], mapNodeLongBookshelfIndices[3] - 2)
        connect(mapNodeShortBookshelfIndices[1], mapNodeLongBookshelfIndices[7] - 2)
        connect(mapNodeShortBookshelfIndices[2], mapNodeLongBookshelfIndices[3] - 4)
        connect(mapNodeShortBookshelfIndices[3], mapNodeLongBookshelfIndices[7] - 4)
        
        // connect the top seats to the nearest walking nodes by hard coding
        connect(seatMapNodeIndices[0], mapNodeLongBookshelfIndices[3] - 4)
        connect(seatMapNodeIndices[0], mapNodeShortBookshelfIndices[2])
        connect(seatMapNodeIndices[2], mapNodeShortBookshelfIndices[2])
        connect(seatMapNodeIndices[2], mapNodeShortBookshelfIndices[3])
        connect(seatMapNodeIndices[4], mapNodeShortBookshelfIndices[3])
        connect(seatMapNodeIndices[4], mapNodeLongBookshelfIndices[7] - 4)
        
        // connect the bottom seats to the nearest walking nodes by hard coding
        connect(seatMapNodeIndices[1], mapNodeLongBookshelfIndices[2])
        connect(seatMapNodeIndices[3], mapNodeLongBookshelfIndices[2])
        connect(seatMapNodeIndices[3], mapNodeLongBookshelfIndices[6])
        connect(seatMapNodeIndices[5], mapNodeLongBookshelfIndices[6])
        
        // connect the side seats to the nearest walking nodes by hard coding
        connect(seatMapNodeIndices[6], mapNodeLongBookshelfIndices[2])
        connect(seatMapNodeIndices[6], mapNodeLongBookshelfIndices[2] + 1)
        connect(seatMapNodeIndices[7], mapNodeLongBookshelfIndices[6])
        connect(seatMapNodeIndices[7], mapNodeLongBookshelfIndices[6] + 1)
        connect(seatMapNodeIndices[8], mapNodeLongBookshelfIndices[2] + 1)
        connect(seatMapNodeIndices[9], mapNodeLongBookshelfIndices[6] + 1)
        connect(seatMapNodeIndices[10], mapNodeLongBookshelfIndices[2] + 3)
        connect(seatMapNodeIndices[11], mapNodeLongBookshelfIndices[6] + 3)
        connect(seatMapNodeIndices[12], mapNodeLongBookshelfIndices[2] + 3)
        connect(seatMapNodeIndices[13], mapNodeLongBookshelfIndices[6] + 3)
        connect(seatMapNodeIndices[14], mapNodeLongBookshelfIndices[2] + 5)
        connect(seatMapNodeIndices[15], mapNodeLongBookshelfIndices[6] + 5)
        
        var interactableNodes: [Int32] = []
        interactableNodes.append(contentsOf:seatMapNodeIndices.shuffled().prefix(8).map {Int32($0)})
        interactableNodes.append(contentsOf:interactableNodesAtBookshelves.shuffled().prefix(8))
        interactableNodes = interactableNodes.shuffled()
        building.data.z = Int32(interactableNodes.count)
        for (i, interactableNode) in interactableNodes.enumerated() {
            building.interactableNodes[i] = interactableNode
        }
      
        // connect the map node with the interior entrance nodes
        for interiorEntranceNodeIndex in interiorEntranceNodeIndices {
            let position = self.mapNodes[interiorEntranceNodeIndex].position
            let array = nodePositionIndexArray.sorted {
                distance(position, $0.0) < distance(position, $1.0)
            }
            connect(interiorEntranceNodeIndex, array[0].1)
            connect(interiorEntranceNodeIndex, array[1].1)
        }
    }
}
