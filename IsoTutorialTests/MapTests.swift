//
//  MapTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 17/02/2024.
//

import Foundation
import XCTest
@testable import IsoTutorial

final class MapTests: XCTestCase {
    
    // MARK: Fixtures
    static let EXAMPLE_HEIGHTMAP = [
        [1,1,1,1,1],
        [1,3,3,3,1],
        [1,3,4,4,1],
        [1,2,2,2,1],
        [1,1,1,1,1],
        [1,1,1,1,1],
    ]
    
    static let EXAMPLE_HEIGHTMAP_ROW_COUNT = EXAMPLE_HEIGHTMAP.count
    static let EXAMPLE_HEIGHTMAP_COL_COUNT = EXAMPLE_HEIGHTMAP[0].count
    
    static let EXAMPLE_HEIGHTMAP_COORDS_OUTSIZE_OF_MAP = [
        Vector2D(x: -1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT - 1),
        Vector2D(x: -1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT),
        Vector2D(x: -1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        Vector2D(x: 0, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        Vector2D(x: 1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT - 1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT + 1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: EXAMPLE_HEIGHTMAP_ROW_COUNT - 1),
        
        Vector2D(x: -1, y: 1),
        Vector2D(x: -1, y: 0),
        Vector2D(x: -1, y: -1),
        Vector2D(x: 0, y: -1),
        Vector2D(x: 1, y: -1),
        
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT - 1, y: -1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT, y: -1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: -1),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: 0),
        Vector2D(x: EXAMPLE_HEIGHTMAP_COL_COUNT + 1, y: 1),
    ]
    
    // MARK: Map basics
    func test_emptyMap_hasZeroWidthAndHeight() {
        let map = Map()
        XCTAssertEqual(map.colCount, 0)
        XCTAssertEqual(map.rowCount, 0)
    }
        
    func map_create_withHeightMap_setsHeightAndWidth() {
        
        
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        
        XCTAssertEqual(map.rowCount, Self.EXAMPLE_HEIGHTMAP_ROW_COUNT)
        XCTAssertEqual(map.colCount, Self.EXAMPLE_HEIGHTMAP_COL_COUNT)
    }
    
    func test_subscript_returnsNegativeHeight_forCoordOutsideOfHeightmap() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        
        for testCoord in Self.EXAMPLE_HEIGHTMAP_COORDS_OUTSIZE_OF_MAP {
            XCTAssertLessThan(map[testCoord], 0)
        }
    }
    
    func test_subscript_returnsHeight_forCoordWithingHeightmap() {
        
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        
        for row in 0 ..< map.rowCount {
            for col in 0 ..< map.colCount {
                XCTAssertEqual(map[Vector2D(x: col, y: row)], Self.EXAMPLE_HEIGHTMAP[row][col])
            }
        }
    }
    
    func test_convertTo3D_xySameAsInput() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        for y in -3 ... 3 {
            for x in -3 ... 3 {
                let coord = Vector2D(x: x, y: y)
                let result = map.convertTo3D(coord)
                XCTAssertEqual(result.xy, coord)
            }
        }
    }
    
    func test_convertTo3D_zProperty_isElevation() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        for y in -3 ... 3 {
            for x in -3 ... 3 {
                let coord = Vector2D(x: x, y: y)
                let result = map.convertTo3D(coord)
                XCTAssertEqual(result.z, map[coord])
            }
        }
    }
    
    // MARK: Pathfinding
    func test_createDijkstra_noHeightDifferences() {
        let map = Map(heightMap: [
            [1,1,1,1],
            [1,1,1,1],
            [1,1,1,1],
            [1,1,1,1],
        ])
        
        let dijkstra = map.dijkstra(target: .zero)
        
        let expectedResult = [
          [0,1,2,3],
          [1,2,3,4],
          [2,3,4,5],
          [3,4,5,6]
        ]
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                XCTAssertEqual(dijkstra[Vector2D(x: x, y: y)], expectedResult[y][x])
            }
        }
    }
    
    func test_createDijkstra_withHeightDifferences() {
        let map = Map(heightMap: [
            [1,1,1,1],
            [1,2,2,1],
            [1,1,3,1],
            [1,1,1,1],
        ])
        
        let dijkstra = map.dijkstra(target: .zero)
        
        let expectedResult = [
          [0,1,2,3],
          [1,3,4,4],
          [2,3,6,5],
          [3,4,5,6],
        ]
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                XCTAssertEqual(dijkstra[Vector2D(x: x, y: y)], expectedResult[y][x])
            }
        }
    }
    
    func test_createDijkstra_withHeightDifferences_startingElsewhere() {
        let map = Map(heightMap: [
            [1,1,1,1],
            [1,2,2,1],
            [1,1,3,1],
            [1,1,1,1],
        ])
        
        let dijkstra = map.dijkstra(target: Vector2D(x: 1, y: 2))
        
        let expectedResult = [
            [3,4,5,6],
            [2,2,3,5],
            [1,0,3,4],
            [2,1,2,3]
        ]
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                XCTAssertEqual(dijkstra[Vector2D(x: x, y: y)], expectedResult[y][x])
            }
        }
    }
    
    func test_withExampleMap() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        
        let dijkstra = map.dijkstra(target: .zero)
        
        let expectedResult = [
            [0,1,2,3,4],
            [1,4,5,6,5],
            [2,5,7,8,6],
            [3,5,6,7,7],
            [4,5,6,7,8],
            [5,6,7,8,9]
        ]
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                XCTAssertEqual(dijkstra[Vector2D(x: x, y: y)], expectedResult[y][x])
            }
        }
    }
    
    func test_dijkstra_performance() {
        let heightmap = (0 ..< 100).map { _ in
            (0 ..< 100).map { _ in Int.random(in: 1..<5) }
        }
        
        let map = Map(heightMap: heightmap)
        
        var i = 0
        measure {
            print("test_dijkstra_performance - round \(i)")
            _ = map.dijkstra(target: map.tiles.keys.randomElement()!)
            i += 1
        }
    }
    
    func test_getPath_inExampleMap() {
        // get a path from (0,0) to (3,1)
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        
        // Create a Dijkstra Map with the starting coordinate as target.
        let dijkstra = map.dijkstra(target: .zero)
        
        // Get the path from (0,0) to (3,1) using the Dijkstra Map.
        let path = map.getPath(to: Vector2D(x: 3, y: 1), using: dijkstra)
                
        let expectedPath =
        [(0,0),(1,0),(2,0),(3,0),(3,1)].map { Vector2D(x: $0.0, y: $0.1) }
        
        XCTAssertEqual(path,expectedPath)
    }
    
    func test_getPath_returnsEmptyPath_ifTargetLocation_isNotOnMap() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        let dijkstra = map.dijkstra(target: .zero)
        
        let path = map.getPath(to: Vector2D(x: 6, y: 9), using: dijkstra)

        XCTAssertEqual(path,[])
    }
    
    func test_dijkstra_takesMaximumHeightDifference_intoAccount() {
        let map = Map(heightMap: Self.EXAMPLE_HEIGHTMAP)
        let dijkstra = map.dijkstra(target: .zero, maxHeightDifference: 1)
        let expectedResult = [
            [0,1,2,3,4],
            [1,8,9,10,5],
            [2,7,9,10,6],
            [3,5,6,7,7],
            [4,5,6,7,8],
            [5,6,7,8,9],
        ]
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                XCTAssertEqual(dijkstra[Vector2D(x: x, y: y)], expectedResult[y][x])
            }
        }
    }
    
    func test_getPath_takesMaximumHeightDifference_intoAccount() {
        let map = Map(heightMap: [
            [1,1,1,1],
            [1,1,8,6],
            [1,1,2,4],
        ])
        
        let dijkstra = map.dijkstra(target: .zero, maxHeightDifference: 2)
        
        let path = map.getPath(to: Vector2D(x: 2, y: 1), using: dijkstra, maxHeightDifference: 2)

        let expected = [
            Vector2D(x: 0, y: 0),
            Vector2D(x: 0, y: 1),
            Vector2D(x: 0, y: 2),
            Vector2D(x: 1, y: 2),
            Vector2D(x: 2, y: 2),
            Vector2D(x: 3, y: 2),
            Vector2D(x: 3, y: 1),
            Vector2D(x: 2, y: 1)
        ]
        
        XCTAssertEqual(path, expected)
        
    }
    
    func test_getPath_returnsEmptyPath_ifHeightDifferenceIsMoreThanMax() {
        let map = Map(heightMap: [
            [1,1,1,1],
            [1,1,1,1],
            [1,1,8,1],
            [1,1,1,1],
        ])
        let dijkstra = map.dijkstra(target: .zero)
        
        let path = map.getPath(to: Vector2D(x: 2, y: 2), using: dijkstra, maxHeightDifference: 4)

        XCTAssertEqual(path, [])
        
    }
}
