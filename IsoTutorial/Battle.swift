//
//  Battle.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 01/06/2024.
//

import Foundation

final class Battle {
    enum BattleState: Equatable {
        case undecided
        case draw
        case won(team: String)
    }
    
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
    
    var undefeatedEntities: [Entity] {
        entities.filter { $0.isActive }
    }
    
    var activeTeam: String {
        undefeatedEntities.first { $0.hasActed == false }?.team ?? ""
    }
    
    private func checkNextTurn() {
        if _entities.filter({ $0.hasActed == false && $0.isActive }).count == 0 {
            for entity in _entities {
                entity.hasActed = false
            }
        }
    }
    
    var state: BattleState {
        let undefeatedTeams = undefeatedEntities.map { $0.team }
            .reduce(into: [String]()) { result, teamName in
                if result.contains(teamName) == false {
                    result.append(teamName)
                }
            }
        
        switch undefeatedTeams.count {
        case 0:
            return .draw
        case 1:
            return .won(team: undefeatedTeams[0])
        default:
            return .undecided
        }
    }
}
