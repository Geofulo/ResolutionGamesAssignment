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
    var planeModels: [PlaneModel] = []
    var selectedPlane: PlaneModel?
    
    // MARK: - Init
    override init() {
        super.init()
        
        setup()
//        setupCoachingOverlay()
        setupGestures()
        subscribeToControl()
    }
}

// MARK: - Private functions
extension ARSessionStore {
    private func setup() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        
        arView.debugOptions = [.showPhysics, .showWorldOrigin]
        arView.session.delegate = self
        arView.session.run(configuration, options: [.removeExistingAnchors])
    }
    
    private func subscribeToControl() {
        ARSessionControl
            .actionSteam
            .sink { [self] action in
                switch action {
                case .restartObjects:
                    setup()
                    selectedPlane = nil
                    planeModels.removeAll()
                    
                    restartCubeModels()
                }
            }
            .store(in: &cancellables)
    }
    
    private func addCubeModels(relativePosition: SIMD3<Float>) {
        guard let plane = selectedPlane else { return }
        
        let cubeRed = CubeModel(category: .red, anchor: plane.planeAnchor)
        cubeRed.prepare(for: arView.scene)
        cubeRed.setInitialPosition(position: relativePosition, relativeToPlane: plane.entity)
        cubeModels.append(cubeRed)

        let cubeBlue = CubeModel(category: .blue, anchor: plane.planeAnchor)
        cubeBlue.prepare(for: arView.scene)
        cubeBlue.setInitialPosition(position: relativePosition, relativeToPlane: plane.entity)
        cubeModels.append(cubeBlue)
    }
    
    private func restartCubeModels() {
        for model in cubeModels {
            arView.scene.removeAnchor(model.anchor)
        }
        cubeModels.removeAll()
    }
}

// MARK: - Gestures
extension ARSessionStore {
    func setupGestures() {
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: arView),
              let hitEntity = arView.entity(at: touchInView)
        else { return }
        
        if let cubeModel = cubeModels.first(where: { $0.isEqual(to: hitEntity) }),
           let cameraTransform = arView.session.currentFrame?.camera.transform {
            cubeModel.impulse(from: -normalize(simd_make_float3(cameraTransform.columns.2)))
        }
        
        if let planeModel = planeModels.first(where: { $0.isEqual(to: hitEntity) }), 
            selectedPlane == nil {
            selectedPlane = planeModel
            selectedPlane?.selectPlane()
            addCubeModels(relativePosition: planeModel.planeAnchor.center)
            for plane in planeModels {
                if !plane.isEqual(to: planeModel.entity) {
                    arView.scene.removeAnchor(plane.anchor)
                }
            }
            planeModels = [planeModel]
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
}

// MARK: - ARSessionDelegate
extension ARSessionStore: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor,
               planeAnchor.alignment == .horizontal,
               selectedPlane == nil {
                let planeModel = PlaneModel(anchor: planeAnchor)
                planeModel.prepare(for: arView.scene)
                planeModels.append(planeModel)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                guard var planeModel = planeModels.first(where: { $0.planeAnchor.identifier == planeAnchor.identifier }) else { return }
                planeModel.update(with: planeAnchor)
            }
        }
    }
}
