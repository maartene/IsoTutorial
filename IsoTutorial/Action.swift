//
//  Action.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 30/03/2024.
//

import Foundation

protocol Action {
    var description: String { get }
    var canComplete: Bool { get }
    
    func complete()
    
    static func make(in map: Map, for entity: Entity, targetting: Vector3D) -> Self?
    static func reachableTiles(in map: Map, for entity: Entity) -> [Vector3D]
}

extension Action {
    func complete() {
        print("Completing action \(self)")
    }
    
    var description: String {
        "\(self)"
    }
    
    var canComplete: Bool {
        true
    }
    
    /// Default implementation for reachableTiles that returns all coordinates in the `map`.
    static func reachableTiles(in map: Map, for entity: Entity) -> [Vector3D] {
        map.tiles.keys.map { map.convertTo3D($0) }
    }
}

struct DummyAction: Action {
    static func make(in map: Map, for entity: Entity, targetting: Vector3D) -> DummyAction? {
        DummyAction()
    }
}

struct MoveAction: Action {
    weak var owner: Entity?
    let path: [Vector3D]
    
    static func reachableTiles(in map: Map, for entity: Entity) -> [Vector3D] {
        let dijkstra = map.dijkstra(target: entity.position.xy, maxHeightDifference: entity.maxHeightDifference)
        
        // FIXME: hard coded max range value
        return dijkstra.filter { $0.value <= entity.range }
            .map { map.convertTo3D($0.key) }
    }
    
    static func make(in map: Map, for entity: Entity, targetting: Vector3D) -> MoveAction? {
        guard reachableTiles(in: map, for: entity).contains(targetting)  else {
            return nil
        }
        
        let dijkstra = map.dijkstra(target: entity.position.xy, maxHeightDifference: entity.maxHeightDifference)
        let path = map.getPath(to: targetting.xy, using: dijkstra, maxHeightDifference: entity.maxHeightDifference).map { map.convertTo3D($0) }
        return MoveAction(owner: entity, path: path)
    }
    
    func complete() {
        guard let owner else {
            return
        }
        
        if path.count >= 2 {
            owner.position = path[path.count - 1]
            owner.rotation = Rotation.fromLookDirection(path[path.count - 1].xy - path[path.count - 2].xy) ?? owner.rotation
        }
    }
    
    var description: String {
        if let lastCoord = path.last {
            return "Move to (\(lastCoord.x),\(lastCoord.y))"
        }
        return "Move to..."
    }
    
    var canComplete: Bool {
        path.isEmpty == false
    }
}
