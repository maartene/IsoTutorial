//
//  ViewModelTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 01/04/2024.
//

import Foundation
import XCTest
import Combine
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
    var cancellables = Set<AnyCancellable>()
    var receivedTiles = [Vector3D?]()
    var receivedEntities = [Entity?]()
    
    func registerForChanges(viewModel: ViewModel) {
        viewModel.$selectedTile.sink { value in
            self.receivedTiles.append(value)
        }.store(in: &cancellables)
        
        viewModel.$selectedEntity.sink { value in
            self.receivedEntities.append(value)
        }.store(in: &cancellables)
    }
    
    func test_selectedTile_publishesChange_when_selectedTile_isChanged() {
        let viewModel = ViewModel(map: Map(), entities: [])
        registerForChanges(viewModel: viewModel)

        let randomCoords = (0 ..< 20).map { _ in Vector3D.random }
        
        for randomCoord in randomCoords {
            viewModel.selectedTile = randomCoord
        }
        
        XCTAssertEqual(receivedTiles.compactMap({$0}), randomCoords)
    }
    
    func test_selectedTile_publishesChange_whenSelectedTile_isSetToNil() throws {
        let viewModel = ViewModel(map: Map(), entities: [])
        registerForChanges(viewModel: viewModel)
        
        viewModel.selectedTile = .random
        XCTAssertNotNil(try XCTUnwrap(receivedTiles.last))
        
        viewModel.selectedTile = nil
        XCTAssertNil(try XCTUnwrap(receivedTiles.last))
    }
    
    func test_selectedEntity_publishesChange_when_selectedEntity_isChanged() {
        let entity = Entity(sprite: "Example Entity", startPosition: .random)
        
        let viewModel = ViewModel(map: Map(), entities: [entity])
        registerForChanges(viewModel: viewModel)
        
        viewModel.selectedEntity = entity
        
        XCTAssertTrue(receivedEntities.compactMap({ $0 }).last === entity)
    }
    
    func test_selectedEntity_publishesChange_when_selectedEntity_isSetToNil() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: .random)
        
        let viewModel = ViewModel(map: Map(), entities: [entity])
        registerForChanges(viewModel: viewModel)

        viewModel.selectedEntity = entity
        XCTAssertNotNil(try XCTUnwrap(receivedEntities.last))
        
        viewModel.selectedEntity = nil
        XCTAssertNil(try XCTUnwrap(receivedEntities.last))
    }
}
