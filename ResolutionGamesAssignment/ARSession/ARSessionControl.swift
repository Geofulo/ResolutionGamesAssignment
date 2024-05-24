//
//  ARSessionControl.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-28.
//

import Foundation
import Combine

struct ARSessionControl {
    static var actionSteam = PassthroughSubject<ARSessionControlAction, Never>()
    
    enum ARSessionControlAction {
        case restartObjects
    }
}
