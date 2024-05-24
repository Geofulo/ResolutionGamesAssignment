//
//  CubeModel.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-26.
//

import Foundation
import Combine
import RealityKit
import ARKit

class CubeModel: ARModelBase {
    // MARK: - Enums
    enum Category {
        case red
        case blue
    }
    
    enum Action {
        case jumpCloser
        case jumpFarAway
    }
    
    // MARK: - Properties
    let category: Category
    private(set) var anchor: AnchorEntity
    private(set) var entity: ModelEntity = .init()
    
    private var resourceToken: ResourceLoader.Token {
        switch category {
        case .red:
            return .cubeRed
        case .blue:
            return .cubeBlue
        }
    }
    
    // MARK: - Init
    init(category: Category, anchor: ARAnchor) {
        self.category = category
        self.anchor = AnchorEntity(anchor: anchor)
        if let newEntity = ResourceLoader.shared.getResourceBy(token: resourceToken) {
            self.entity = newEntity
        }
    }
}

// MARK: - ARModelBase Protocol
extension CubeModel {
    func prepare(for scene: Scene) {
        entity.physicsBody = PhysicsBodyComponent(mode: .dynamic)
        entity.generateCollisionShapes(recursive: true)
        
        anchor.addChild(entity)
        
        setInitialPosition()
        
        scene.addAnchor(anchor)        
    }
}

// MARK: - Private functions
extension CubeModel {
    private func setInitialPosition() {
        switch category {
        case .red:
            entity.setPosition([0.2, 0.5, 0], relativeTo: nil)
        case .blue:
            entity.setPosition([-0.2, 0.5, 0], relativeTo: nil)
        }
    }
}

// MARK: - Public functions
extension CubeModel {
    func run(action: Action, relativeTo destinationEntity: ModelEntity) {
        switch action {
        case .jumpCloser:
            let x = destinationEntity.position.x - entity.position.x
            let z = destinationEntity.position.z - entity.position.z
            entity.applyLinearImpulse([x, 1, z], relativeTo: nil)
        case .jumpFarAway:
            let x = entity.position.x - destinationEntity.position.x
            let z = entity.position.z - destinationEntity.position.z
            entity.applyLinearImpulse([x, 1, z], relativeTo: nil)
        }
    }
    
    func isEqual(to otherEntity: Entity) -> Bool {
        return entity.id == otherEntity.id
    }
}
