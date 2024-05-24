//
//  ARModelBase.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-27.
//

import Foundation
import RealityKit
import ARKit

protocol ARModelBase {
    var anchor: AnchorEntity { get }
    var entity: ModelEntity { get }
    
    func prepare(for scene: Scene)
}
