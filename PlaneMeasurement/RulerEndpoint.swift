//
//  RulerEndpoint.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/16/24.
//

import SceneKit
import SpriteKit

class RulerEndpoint: SCNNode {


    var point: CGPoint
    private(set) var hasValidHitTarget: Bool = false

    init(at point: CGPoint) {
        self.point = point

        super.init()
        self.createEndpointNode(color: .white.withAlphaComponent(0.8))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPosition(_ position: SCNVector3?) {
        if let position {
            self.position = position
            hasValidHitTarget = true
        } else {
            hasValidHitTarget = false
        }
    }

    func toSKNode() -> SKShapeNode {
        let color: UIColor = hasValidHitTarget ? .white.withAlphaComponent(0.8) : .red.withAlphaComponent(0.8)
        let circle = SKShapeNode(circleOfRadius: 10)
        circle.position = skPoint(point)
        circle.strokeColor = color
        circle.glowWidth = 1.0
        circle.fillColor = color
        circle.position = skPoint(point)
        return circle
    }

    private func createEndpointNode(color: UIColor) {
        let sphere = SCNSphere(radius: 0.01)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = color
        sphere.materials = [sphereMaterial]
        let endpointNode = SCNNode(geometry: sphere)
        addChildNode(endpointNode)
    }
}


