//
//  Map.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 17/02/2024.
//

import Foundation

enum TileType {
    case void
    case terrain
}

struct Map {
    let colCount: Int
    let rowCount: Int
    let tiles: [Vector2D: Int]
    
    init() {
        colCount = 0
        rowCount = 0
        tiles = [:]
    }
    
    init(heightMap: [[Int]]) {
        rowCount = heightMap.count
        colCount = heightMap.first?.count ?? 0
        var tiles = [Vector2D: Int]()
        
        for row in 0 ..< rowCount {
            for col in 0 ..< colCount {
                let elevation = heightMap[row][col]
                tiles[Vector2D(x: col, y: row)] = elevation
            }
        }
        
        self.tiles = tiles
    }
    
    subscript(coord: Vector2D) -> Int {
        tiles[coord, default: -1]
    }
    
    func convertTo3D(_ coord: Vector2D) -> Vector3D {
        Vector3D(x: coord.x, y: coord.y, z: self[coord])
    }
}
