//
//  Action.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 30/03/2024.
//

import Foundation

protocol Action {
    func complete()
}

extension Action {
    func complete() {
        print("Completing action \(self)")
    }
}

struct DummyAction: Action {
    
}

struct MoveAction: Action {
    let owner: Entity?
    let path: [Vector3D]
    
    func complete() {
        guard let owner else {
            return
        }
        
        if path.count >= 2 {
            owner.position = path[path.count - 1]
            owner.rotation = Rotation.fromLookDirection(path[path.count - 1].xy - path[path.count - 2].xy) ?? owner.rotation
        }
    }
}
