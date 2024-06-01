//
//  Battle.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 01/06/2024.
//

import Foundation

final class Battle {
    private let _entities: [Entity]
    
    init(entities: [Entity]) {
        _entities = entities
    }
    
    var teams: [String] {
        let teamNames = _entities.map { $0.team }
        return teamNames.reduce(into: [String](), { result, teamName in
            if result.contains(teamName) == false {
                result.append(teamName)
            }
        })
    }
    
    var entities: [Entity] {
        checkNextTurn()
        return _entities
    }
    
    var activeTeam: String {
        entities.first { $0.hasActed == false }?.team ?? ""
    }
    
    func checkNextTurn() {
        if _entities.filter({ $0.hasActed == false }).count == 0 {
            for entity in _entities {
                entity.hasActed = false
            }
        }
    }
}
