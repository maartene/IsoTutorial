//
//  ViewModelTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 01/04/2024.
//

import Foundation
import XCTest
@testable import IsoTutorial



final class ViewModelTests: XCTestCase {
    
    let exampleMap = Map(heightMap: [
        [1,1,1,1,1],
        [1,1,1,1,1],
        [1,1,2,2,1],
        [2,4,2,3,1],
        [1,1,1,1,1]
    ])
    
    func test_clickTile_selectsTile_whenNoTileIsSelected() {
        let viewModel = ViewModel(map: exampleMap, entities: [])
           
        XCTAssertNil(viewModel.selectedTile)
        
        viewModel.clickTile(Vector3D(x: 2, y: 3, z: 2))
        
        XCTAssertEqual(viewModel.selectedTile, Vector3D(x: 2, y: 3, z: 2))
                                        
    }
    
    func test_clickTile_deselectsTile_whenATileOutsideOfMap_isClicked() {
        let viewModel = ViewModel(map: exampleMap, entities: [])
        viewModel.selectedTile = .random
        
        viewModel.clickTile(Vector3D(x: -100, y: 100, z: -100))
        
        XCTAssertNil(viewModel.selectedTile)
    }
    
    func test_clickTile_selectsEntity_whenATileWithAnEntity_isClicked() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: .random)
        let viewModel = ViewModel(map: exampleMap, entities: [entity])
        
        XCTAssertNil(viewModel.selectedEntity)
        
        viewModel.clickTile(entity.position)
        
        let selectedEntity  = try  XCTUnwrap(viewModel.selectedEntity)
        XCTAssertTrue(selectedEntity === entity)
    }
    
    func test_clickTile_deselectsEntity_whenATileWithoutAnEntity_isClicked() {
        let entity = Entity(sprite: "Example Entity", startPosition: .random)
        let viewModel = ViewModel(map: exampleMap, entities: [entity])
        viewModel.selectedEntity = entity
        
        viewModel.clickTile(entity.position + Vector3D(x: 1, y: 0))
        
        XCTAssertNil(viewModel.selectedEntity)
    }
    
    // MARK: Combine tests
    func test_selectedTile_publishesChange_when_selectedTile_isChanged() {
        let viewModel = ViewModel(map: Map(), entities: [])
        
        let randomCoords = (0 ..< 20).map { _ in Vector3D.random }
                
        var receivedValues = [Vector3D]()
        
        let sink = viewModel.$selectedTile.sink { value in
            guard let value else {
                return
            }
            
            receivedValues.append(value)
        }
        
        for randomCoord in randomCoords {
            viewModel.selectedTile = randomCoord
        }
        
        XCTAssertEqual(receivedValues, randomCoords)
    }
    
    func test_selectedEntity_publishesChange_when_selectedEntity_isChanged() {
        let entity = Entity(sprite: "Example Entity", startPosition: .random)
        
        let viewModel = ViewModel(map: Map(), entities: [])
        
        var receivedValues = [Entity]()
        
        let sink = viewModel.$selectedEntity.sink { value in
            guard let value else {
                return
            }
            
            receivedValues.append(value)
        }
        
        viewModel.selectedEntity = entity
        
        XCTAssertTrue(receivedValues.last === entity)
    }
}
