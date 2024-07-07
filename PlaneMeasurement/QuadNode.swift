//
//  RulerNode.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/14/24.
//

import SceneKit
import SpriteKit

class QuadNode: SCNNode {

    // for hit testing
    var sceneView: SCNView

    // 0 ----------------- 1
    // |                   |
    // |                   |
    // |                   |
    // |                   |
    // 3 ----------------- 2

    // size of 4
    var endpoints = [RulerEndpoint]()
    
    // ResetButton
    var resetButton: UIButton?
    
    // Instruction
    var instructionLabel: UILabel?

    init(sceneView: SCNView, resetButton: UIButton?, instructionLabel: UILabel?) {
        self.sceneView = sceneView
        self.resetButton = resetButton
        self.instructionLabel = instructionLabel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func beginNewMeasurement(point: CGPoint) {
        endpoints = [RulerEndpoint(at: point), RulerEndpoint(at: point), RulerEndpoint(at: point), RulerEndpoint(at: point)]
        for endpoint in endpoints {
            addChildNode(endpoint)
        }
        //instructionLabel?.removeFromSuperview()
        //instructionLabel = nil
        // Show the Reset button
        resetButton?.isHidden = false
        instructionLabel?.isHidden = true
        
    }

    func editMeasurement(vertex: Int, point: CGPoint, squared: Bool) {
        if vertex > 3 || vertex < 0 {
            fatalError("")
        }
        endpoints[vertex].point = point
        if squared {
            adjustPointsToSquare(vertex: vertex)
        }
        for endpoint in endpoints {
            endpoint.setPosition(endpoint.position)
        }
    }

    func resetMeasurement() {
        for endpoint in endpoints {
            endpoint.removeFromParentNode()
        }
        endpoints = []
        
    }
    
    func resetNodes() {
        for endpoint in endpoints {
            endpoint.removeFromParentNode()
        }
    }

    private func adjustPointsToSquare(vertex: Int) {
        let endpoint0 = endpoints[vertex]
        let endpoint2 = endpoints[(vertex + 2) % 4]

        let endpoint1 = endpoints[(vertex + 1) % 4]
        let endpoint3 = endpoints[(vertex + 3) % 4]

        if vertex % 2 == 0 {
            endpoint1.point.y = endpoint0.point.y
            endpoint1.point.x = endpoint2.point.x
            endpoint3.point.x = endpoint0.point.x
            endpoint3.point.y = endpoint2.point.y
        } else {
            endpoint1.point.y = endpoint2.point.y
            endpoint1.point.x = endpoint0.point.x
            endpoint3.point.x = endpoint2.point.x
            endpoint3.point.y = endpoint0.point.y
        }
    }


    func hitTestVertices() {
        for endpoint in endpoints {
            var position: SCNVector3? = nil
            if let hitTestResult = hitTest(at: endpoint.point) {
                position = hitTestResult.worldCoordinates
            }
            endpoint.setPosition(position)
        }
        provideHapticFeedback()
    }
    
    // Provide haptic feedback on user interactions
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }


    func hitTest(at point: CGPoint) -> SCNHitTestResult? {
        let hitResults = sceneView.hitTest(point)

        return hitResults.first
    }

    func getIntersectingVertex(at point: CGPoint) -> Int?  {
        if endpoints.isEmpty { return nil }
        for i in [0,1,2,3] {
            let endpoint = endpoints[i]
            let dist = pointDistance(from: point, to: endpoint.point)
            if dist < 30 {
                return i
            }
        }
        provideHapticFeedback()
        return nil
    }

    func updateSKNode() -> SKNode? {
        if endpoints.isEmpty { return nil }

        let node = SKNode()
        for i in [0,1,2,3] {
            let endpoint1 = endpoints[i]
            let endpoint2 = endpoints[(i+1) % 4]

            let endpointNode = endpoint1.toSKNode()
            endpointNode.name = "\(i)"
            let line = drawSKLine(from: endpoint1.point, to: endpoint2.point)
            let midpoint = midpoint(between: (endpoint1.point, endpoint2.point))
            let pill = drawSKRectangle(at: midpoint)
            let distance = calculateDistanceInInches(from: endpoint1.position, to: endpoint2.position)

            let distanceString = String(format: "%.2f", distance)
            let text = drawSKText(text: distanceString, at: midpoint)

            node.addChild(endpointNode)
            node.addChild(line)
            node.addChild(pill)
            node.addChild(text)
        }

        return node
    }


    private func drawSKEndpoint(at point: CGPoint) -> SKNode {
        let circle = SKShapeNode(circleOfRadius: 6)
        circle.position = skPoint(point)
        circle.strokeColor = .white.withAlphaComponent(0.8)
        circle.glowWidth = 1.0
        circle.fillColor = .white.withAlphaComponent(0.8)
        return circle
    }

    private func drawSKLine(from firstPoint: CGPoint, to secondPoint: CGPoint) -> SKNode {
        let line = SKShapeNode()
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: skPoint(firstPoint))
        pathToDraw.addLine(to: skPoint(secondPoint))
        line.path = pathToDraw
        line.lineWidth = 3
        line.strokeColor = .white.withAlphaComponent(0.8)
        return line
    }


    private func drawSKRectangle(at point: CGPoint) -> SKNode {
        let rect = SKShapeNode(rectOf: CGSize(width: 70, height: 35), cornerRadius: 18)
        rect.fillColor = .white.withAlphaComponent(0.8)
        rect.strokeColor = .white.withAlphaComponent(0.8)
        rect.position = skPoint(point)
        return rect
    }

    private func drawSKText(text: String, at point: CGPoint) -> SKNode {
        let textNode = SKLabelNode()
        textNode.text = text
        textNode.fontSize = 15
        textNode.fontColor = UIColor.black
        // Create a bold font
        let boldFont = UIFont.boldSystemFont(ofSize: textNode.fontSize)
        textNode.fontName = boldFont.fontName
        textNode.verticalAlignmentMode = .center
        textNode.position = skPoint(point)
        return textNode
    }

    private func midpoint(between points: (CGPoint, CGPoint)) -> CGPoint {
        let midpoint = CGPoint(
            x: Int(0.75 * points.0.x + 0.25 * points.1.x),
            y: Int(0.75 * points.0.y + 0.25 * points.1.y)
        )
        return midpoint
    }


}

func pointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
    return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
}

func pointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt(pointDistanceSquared(from: from, to: to))
}
