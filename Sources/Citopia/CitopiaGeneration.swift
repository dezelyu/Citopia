
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
        
        // initialize the foundationalBuildingBlocks by iterating through the blocks between the grid points
        for x in 0..<self.blockCount {
            for z in 0..<self.blockCount {
                let blockPosition = simd_float2(
                    (Float(x) + 0.5) * (self.blockSideLength + self.blockDistance),
                    (Float(z) + 0.5) * (self.blockSideLength + self.blockDistance)
                )
                let blockSize = simd_float3(
                    self.blockSideLength, Float(Int.random(in: 1...5) * 3),
                    self.blockSideLength
                )
                self.foundationalBuildingBlocks.append((
                    blockPosition + origin,
                    blockSize
                ))
            }
        }
        
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
                        blockSize
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
                        blockSize
                    ))
                }
            }
        }
        
        // save the grid dimension data
        let sideCount = Int(ceil(Float(self.blockCount + 2) / 2.0))
        self.mapGridCount = sideCount * sideCount
        self.gridLengthX = 2 * (self.blockSideLength + self.blockDistance)
        self.gridLengthZ = 2 * (self.blockSideLength + self.blockDistance)
        
        // create the map node buffer
        self.createMapNodeBuffer()
    }
}
