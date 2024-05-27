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
        
        scene.addAnchor(anchor)        
    }
}

// MARK: - Private functions
extension CubeModel {
    func setInitialPosition(position: SIMD3<Float>, relativeToPlane: Entity) {
        switch category {
        case .red:
            entity.setPosition([0, 0, 0], relativeTo: nil)
        case .blue:
            entity.setPosition([0, 0, 0], relativeTo: nil)
        }
    }
}

// MARK: - Public functions
extension CubeModel {
    func impulse(from vector: simd_float3) {
        let magnitude: Float = 1.5
        let impulse = vector * magnitude
        entity.applyLinearImpulse(impulse, relativeTo: nil)
    }
    
    func isEqual(to otherEntity: Entity) -> Bool {
        return entity.id == otherEntity.id
    }
}
