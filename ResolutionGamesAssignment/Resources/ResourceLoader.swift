//
//  ResourceLoader.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-28.
//

import Foundation
import Combine
import RealityKit

class ResourceLoader {
    // MARK: - Tokens
    enum Token: String, CaseIterable {
        case cubeRed = "cube1"
        case cubeBlue = "cube2"
    }
    
    // MARK: - Properties
    static var shared = ResourceLoader()
    private var cancellables = Set<AnyCancellable>()
    
    var resources: [Token: ModelEntity] = [:]
    
    // MARK: - Public functions
    func loadResources() {
        for token in Token.allCases {
            Entity.loadModelAsync(named: token.rawValue)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("Resource \(token.rawValue) loaded")
                    case .failure(_):
                        print("Error loading resource: \(token.rawValue)")
                    }
                } receiveValue: { entity in
                    self.resources.updateValue(entity, forKey: token)
                }
                .store(in: &cancellables)
        }
    }
    
    func getResourceBy(token: Token) -> ModelEntity? {
        resources[token]?.clone(recursive: true)
    }
}
