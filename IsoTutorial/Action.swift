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
    var endsTurn: Bool { get }
    
    func complete()
    
    static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity]) -> Self?
    static func reachableTiles(in map: Map, for entity: Entity, allEntities: [Entity]) -> [Vector3D]
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
    static func reachableTiles(in map: Map, for entity: Entity, allEntities: [Entity] = []) -> [Vector3D] {
        map.tiles.keys.map { map.convertTo3D($0) }
    }
    
    var endsTurn: Bool {
        true
    }
}

struct DummyAction: Action {
    static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity] = []) -> DummyAction? {
        DummyAction()
    }
}

// MARK: MoveAction
struct MoveAction: Action {
    weak var owner: Entity?
    let path: [Vector3D]
    
    static func reachableTiles(in map: Map, for entity: Entity, allEntities: [Entity] = []) -> [Vector3D] {
        let dijkstra = map.dijkstra(target: entity.position.xy, maxHeightDifference: entity.maxHeightDifference)
        let occupiedTiles = allEntities.map { $0.position.xy }
        
        return dijkstra.filter { $0.value <= entity.range }
            .filter { occupiedTiles.contains($0.key) == false }
            .map { map.convertTo3D($0.key) }
    }
    
    static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity] = []) -> MoveAction? {
        guard reachableTiles(in: map, for: entity, allEntities: allEntities).contains(targetting)  else {
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

// MARK: AttackAction
struct AttackAction: Action {
    weak var owner: Entity?
    weak var target: Entity?
    
    static func reachableTiles(in map: Map, for entity: Entity, allEntities: [Entity]) -> [Vector3D] {
        let dijkstra = map.dijkstra(target: entity.position.xy)
        
        return dijkstra.filter { $0.value <= entity.attackRange }
            .map { map.convertTo3D($0.key) }
    }
    
    static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity]) -> AttackAction? {
        
        guard reachableTiles(in: map, for: entity, allEntities: allEntities).contains(targetting) else {
            return nil
        }
        
        guard let targetEntity = allEntities.first(where: { $0.position == targetting }) else {
            return nil
        }
        
        return AttackAction(owner: entity, target: targetEntity)
    }
    
    func complete() {
        target?.takeDamage(3)
        
        guard let owner, let target else {
            return
        }
        
        let attackDirection = Rotation.fromLookDirection(target.position.xy - owner.position.xy) ?? owner.rotation
        
        owner.rotation = attackDirection
        target.rotation = attackDirection.rotated90DegreesClockwise.rotated90DegreesClockwise
    }
    
    var canComplete: Bool {
        target != nil
    }
    
    var description: String {
        "Attack \(target?.sprite ?? "Nothing")"
    }
}

// MARK: TakeDamageAction
struct TakeDamageAction: Action {
    static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity]) -> TakeDamageAction? {
        TakeDamageAction()
    }
    
    let endsTurn = false
}
