//
//  PlaneModel.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-27.
//

import Foundation
import RealityKit
import ARKit

struct PlaneModel {
    // MARK: - Properties
    private(set) var planeAnchor: ARPlaneAnchor
    private(set) var anchor: AnchorEntity
    private(set) var entity: ModelEntity
 
    // MARK: - Init
    init(anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        self.anchor = AnchorEntity(world: anchor.transform)
        self.entity = ModelEntity(
            mesh: MeshResource.generatePlane(width: anchor.planeExtent.width, depth: anchor.planeExtent.height),
            materials: [UnlitMaterial(color: .white.withAlphaComponent(0.2))]
        )
    }    
}

// MARK: - ARModelBase Protocol
extension PlaneModel {
    func prepare(for scene: Scene) {
        entity.physicsBody = PhysicsBodyComponent(mode: .static)
        entity.generateCollisionShapes(recursive: true)
        
        anchor.anchoring = AnchoringComponent(planeAnchor)
        anchor.addChild(entity)
        
        scene.addAnchor(anchor)
    }
}

// MARK: - Public functions
extension PlaneModel {
    mutating func update(with planeAnchor: ARPlaneAnchor) {
        do {
            self.planeAnchor = planeAnchor
            let width = planeAnchor.planeExtent.width
            let depth = planeAnchor.planeExtent.height
            let mesh = MeshResource.generatePlane(width: width, depth: depth)
            try self.entity.model?.mesh.replace(with: mesh.contents)
            self.entity.collision = CollisionComponent(shapes: [.generateBox(width: width, height: 0, depth: depth)])
        } catch {
            print(error.localizedDescription)
        }
    }
}
