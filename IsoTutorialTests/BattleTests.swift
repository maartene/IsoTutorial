//
//  BattleTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 01/06/2024.
//

import Foundation
import XCTest
@testable import IsoTutorial

final class BattleTests: XCTestCase {
    let exampleEntities = [
        Entity(sprite: "Entity 1", startPosition: .zero, team: "Player"),
        Entity(sprite: "Entity 2", startPosition: .zero, team: "Player"),
        Entity(sprite: "Entity 3", startPosition: .zero, team: "AI1"),
        Entity(sprite: "Entity 4", startPosition: .zero, team: "AI1"),
        Entity(sprite: "Entity 5", startPosition: .zero, team: "AI2"),
        Entity(sprite: "Entity 6", startPosition: .zero, team: "AI2")
    ]
    
    func test_aBattle_hasTeams_basedOnEntitiesPassedIn() {
        let battle = Battle(entities: exampleEntities)
        XCTAssertEqual(battle.teams, ["Player", "AI1", "AI2"])
    }
    
    func test_atTheStartOfABattle_theFirstTeam_isTheActiveTeam() {
        let battle = Battle(entities: exampleEntities)
        XCTAssertEqual(battle.activeTeam, "Player")
    }
    
    func test_atStartOfBattle_noEntityHasActed() {
        let battle = Battle(entities: exampleEntities)
        for entity in battle.entities {
            XCTAssertFalse(entity.hasActed)
        }
    }
    
    func test_ifAllMembersOfTheActiveTeam_haveActed_thenTheNextTeam_isTheActiveTeam() {
        let battle = Battle(entities: exampleEntities)
        
        battle.entities[0].hasActed = true
        battle.entities[1].hasActed = true
        
        XCTAssertEqual(battle.activeTeam, "AI1")
    }
    
    func test_ifAllMembersHaveActed_thenTheFirstTeam_isActiveTeam() {
        let battle = Battle(entities: exampleEntities)
        
        battle.entities.forEach { $0.hasActed = true }
        
        XCTAssertEqual(battle.activeTeam, "Player")
    }
    
    func test_ifAllMembersHaveActed_thenAllEntities_haveActed_setToFalse() {
        let battle = Battle(entities: exampleEntities)
        
        battle.entities.forEach { $0.hasActed = true }
        
        for entity in battle.entities {
            XCTAssertFalse(entity.hasActed)
        }
    }
    
    func test_onlyActiveEntities_determineActiveTeam() {
        let battle = Battle(entities: exampleEntities)
        
        battle.entities[0].hasActed = true
        battle.entities[1].currentHP = 0
        
        XCTAssertEqual(battle.activeTeam, "AI1")
    }
    
    // MARK: Battle state
    func test_aNewBattle_isInState_undecided() {
        let battle = Battle(entities: exampleEntities)
        XCTAssertEqual(battle.state, .undecided)
    }
    
    func test_whenAllEntitiesAreDefeated_stateIs_draw() {
        let battle = Battle(entities: exampleEntities)
        battle.entities.forEach { $0.currentHP = 0 }
        XCTAssertEqual(battle.state, .draw)
    }
    
    func test_whenAllEntitiesOfOtherTeamsAreDefeated_stateIsWon() {
        let battle = Battle(entities: exampleEntities)
        
        for i in 0 ..< 5 {
            battle.entities[i].currentHP = 0
        }
        
        guard case .won(_) = battle.state else {
            XCTFail("Expected a 'won' state, found: \(battle.state)")
            return
        }
    }
    
    func test_whenAllEntitiesOfOtherTeamsAreDefeated_wonState_containsWinningTeam() {
        let battle = Battle(entities: exampleEntities)
        
        for i in 0 ..< 5 {
            battle.entities[i].currentHP = 0
        }
        
        guard case .won(let team) = battle.state else {
            XCTFail("Expected a 'won' state, found: \(battle.state)")
            return
        }

        XCTAssertEqual(team, "AI2")
    }
}
