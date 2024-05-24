//
//  ARSessionStore.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-26.
//

import Foundation
import Combine
import RealityKit
import ARKit

final class ARSessionStore: NSObject, ObservableObject {
    // MARK: - Properties
    static var shared = ARSessionStore()
    private var cancellables = Set<AnyCancellable>()
    
    let arView = ARView(frame: .zero)
    let coachingOverlay = ARCoachingOverlayView()
    
    var cubeModels: [CubeModel] = []
    var planeModel: PlaneModel?
    
    // MARK: - Init
    override init() {
        super.init()
        
        setup()
        setupCoachingOverlay()
        setupGestures()
        subscribeToControl()
    }
}

// MARK: - Private functions
extension ARSessionStore {
    private func setup() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.frameSemantics = .personSegmentation
        configuration.environmentTexturing = .automatic
        
        arView.session.delegate = self
        arView.session.run(configuration)
    }
    
    private func subscribeToControl() {
        ARSessionControl.actionSteam
            .sink { action in
                switch action {
                case .restartObjects:
                    self.restartCubeModels()
                }
            }
            .store(in: &cancellables)
    }
    
    private func addCubeModels() {
        guard let anchor = planeModel?.planeAnchor else { return }
        
        let cubeRed = CubeModel(category: .red, anchor: anchor)
        cubeRed.prepare(for: arView.scene)
        cubeModels.append(cubeRed)

        let cubeBlue = CubeModel(category: .blue, anchor: anchor)
        cubeBlue.prepare(for: arView.scene)
        cubeModels.append(cubeBlue)
    }
    
    private func restartCubeModels() {
        for model in cubeModels {
            arView.scene.removeAnchor(model.anchor)
        }
        cubeModels.removeAll()
        
        addCubeModels()
    }
}

// MARK: - Gestures
extension ARSessionStore {
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: arView) else { return }
        guard let hitEntity = arView.entity(at: touchInView) else { return }
        guard let cubeEntity = cubeModels.first(where: { $0.isEqual(to: hitEntity) }) else { return }
        guard let anotherEntity = cubeModels.first(where: { $0.isEqual(to: hitEntity) == false }) else { return }
        
        switch cubeEntity.category {
        case .blue:
            cubeEntity.run(action: .jumpCloser, relativeTo: anotherEntity.entity)
        case .red:
            cubeEntity.run(action: .jumpFarAway, relativeTo: anotherEntity.entity)
        }
        
    }
}

// MARK: - ARCoachingOverlayView
extension ARSessionStore: ARCoachingOverlayViewDelegate {
    private func setupCoachingOverlay() {
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.delegate = self
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.setActive(true, animated: true)
        
        arView.addSubview(coachingOverlay)
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        addCubeModels()
    }
    
}

// MARK: - ARSessionDelegate
extension ARSessionStore: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                if planeModel == nil {
                    planeModel = PlaneModel(anchor: planeAnchor)
                    planeModel?.prepare(for: arView.scene)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                guard var planeModel = planeModel, planeModel.planeAnchor.identifier == planeAnchor.identifier else { return }
                planeModel.update(with: planeAnchor)
            }
        }
    }
}
