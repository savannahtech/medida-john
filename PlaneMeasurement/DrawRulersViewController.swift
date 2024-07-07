//
//  DrawRulersViewController.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/11/24.
//

import UIKit
import SceneKit
import SpriteKit
import MagnifyingGlass
import ARKit

class DrawRulersViewController: UIViewController {


    // MARK: - View Elements
    var scene: SCNScene!
    var sceneView: SCNView!
    var imageView: UIView!
    var tableViewController: TableViewController!

    // MARK: - state from SceneReconstructionVC
    var pointOfView: SCNNode?
    var image: UIImage
    var frame: ARFrame
    var oldRootNode: SCNNode

    // MARK: - keeping track of vertices / edges
    var quadNode: QuadNode!
    var skScene: SKScene {
        sceneView.overlaySKScene!
    }
    var panningState: PanningState = .first
    var dummyNode = SCNNode()
    
    // John variables
    var instructionLabel: UILabel?  // Declared as optional UILabel
    var resetButton: UIButton?


    let magnifyingGlass = MagnifyingGlassView(offset: CGPoint(x: 0, y: -75.0), radius: 50.0, scale: 1, crosshairColor: .black, crosshairWidth: 0.8)


    init(viewSnapshot: UIImage, pov: SCNNode, frame: ARFrame, root: SCNNode) {
        self.image = viewSnapshot
        self.pointOfView = pov
        self.frame = frame
        self.oldRootNode = root
        super.init(nibName: nil, bundle: nil)

        setupScene()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enablePanGesture()

        imageView = UIImageView(image: image)
        imageView.frame = view.frame
        view.addSubview(imageView)

        
        
        setupSceneView()
        showInstructionLabel()
        //showInstructionLabelRounded()
        setupQuadNode()
        setupSKScene()
        setupTableView()
        
        
        
        //showInstructionsPopup()
    }
    
    func showInstructionLabel(){
        
        // Create and add instruction label
        instructionLabel = UILabel()
        instructionLabel?.text = "Tap and Hold on the plane \nto place the first point, then \nDrag to the second point \nand release to complete the measurement."
        instructionLabel?.textColor = .white
        instructionLabel?.numberOfLines = 0
        instructionLabel?.lineBreakMode = .byWordWrapping
        instructionLabel?.textAlignment = .center
        // Create a bold font
        let boldFont = UIFont.boldSystemFont(ofSize: 18)
        instructionLabel?.font = boldFont
        instructionLabel?.translatesAutoresizingMaskIntoConstraints = false
        // Add padding
        //let padding: CGFloat = 16
        view.addSubview(instructionLabel!)

        // Constraints for instruction label
        NSLayoutConstraint.activate([
            instructionLabel!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            instructionLabel!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel!.widthAnchor.constraint(equalToConstant: 300),
            instructionLabel!.heightAnchor.constraint(equalToConstant: 130)
        ])
//        NSLayoutConstraint.activate([
//            instructionLabel!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            instructionLabel!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//        ])

        
        //instructionLabel?.isHidden = false
        // Add tap gesture recognizer to sceneView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func showInstructionLabelRounded() {
        // Create the custom view with rounded corners
        let instructionView = UIView()
        instructionView.backgroundColor = .white
        instructionView.layer.cornerRadius = 20
        instructionView.translatesAutoresizingMaskIntoConstraints = false

        // Create and add the instruction label inside the custom view
        let instructionLabel = UILabel()
        instructionLabel.text = "To start measuring, \ntap and hold on the plane to place the first point. \nThen, drag to the second point and release to complete the measurement."
        instructionLabel.textColor = .black
        instructionLabel.numberOfLines = 0
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.textAlignment = .center

        // Create a bold font
        let boldFont = UIFont.boldSystemFont(ofSize: 18)
        instructionLabel.font = boldFont

        instructionView.addSubview(instructionLabel)

        // Add the custom view to the main view
        view.addSubview(instructionView)

        // Set up constraints for the custom view
        NSLayoutConstraint.activate([
            instructionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            instructionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionView.widthAnchor.constraint(equalToConstant: 300),
            instructionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 130)
        ])

        // Set up constraints for the label inside the custom view
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: instructionView.topAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -16),
            instructionLabel.bottomAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: -16)
        ])

        // Add tap gesture recognizer to sceneView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        // Remove instruction label from superview when tapped
        instructionLabel?.removeFromSuperview()
        instructionLabel = nil  // Set to nil to release the label reference
    }
    
    func showInstructionsPopup() {
        let alert = UIAlertController(title: "Instructions", message: "To start measuring, tap and hold on the plane to place the first point. Then, drag to the second point and release to complete the measurement.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { _ in
                    UserDefaults.standard.set(true, forKey: "hasShownInstructions")
                }))
                
                // Present the alert
                present(alert, animated: true, completion: nil)
        
        
//        let hasShownInstructions = UserDefaults.standard.bool(forKey: "hasShownInstructions")
//            
//            if !hasShownInstructions {
//                let alert = UIAlertController(title: "Instructions", message: "To start measuring, tap and hold on the plane to place the first point. Then, drag to the second point and release to complete the measurement.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: { _ in
//                    UserDefaults.standard.set(true, forKey: "hasShownInstructions")
//                }))
//                present(alert, animated: true, completion: nil)
//            }
    }
    
    func setupResetButton() {
        // Add the Reset button
        resetButton = UIButton(type: .system)
        resetButton?.setTitle("Reset", for: .normal)
        resetButton?.backgroundColor = .white
        resetButton?.setTitleColor(.black, for: .normal)
        resetButton?.layer.cornerRadius = 25
        resetButton?.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        resetButton?.translatesAutoresizingMaskIntoConstraints = false
        // Create a bold font
        let boldFont = UIFont.boldSystemFont(ofSize: resetButton?.titleLabel?.font.pointSize ?? 16)
        resetButton?.titleLabel?.font = boldFont
        
        view.addSubview(resetButton!)

        // Add constraints to position the button at the top-center
        NSLayoutConstraint.activate([
            resetButton!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            resetButton!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton!.widthAnchor.constraint(equalToConstant: 100),
            resetButton!.heightAnchor.constraint(equalToConstant: 50)
        ])

            // Initially hide the Reset button
            resetButton?.isHidden = true
    }
    
    @objc func resetButtonTapped() {
        // Reset the measurement node
        quadNode.resetMeasurement()


        // Hide the Reset button
        resetButton?.isHidden = true
        
        self.quadNode = QuadNode(sceneView: sceneView, resetButton: resetButton, instructionLabel: instructionLabel)
        scene.rootNode.addChildNode(quadNode)
        scene.rootNode.addChildNode(dummyNode)
    }

    // MARK: - Setup
    func setupScene() {
        scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.simdTransform = frame.camera.transform
        scene.rootNode.addChildNode(cameraNode)

        for child in oldRootNode.childNodes {
            scene.rootNode.addChildNode(child)
            child.geometry?.firstMaterial?.colorBufferWriteMask = []
        }
        
        
        
        // Add the Resetbutton, but make it hidden
        setupResetButton()
    }

    func setupSceneView() {
        sceneView = SCNView()
        sceneView.frame = view.frame
        sceneView.backgroundColor = .clear
        sceneView.scene = scene
        sceneView.pointOfView = pointOfView
        sceneView.autoenablesDefaultLighting = false
        view.addSubview(sceneView)
    }

    func setupQuadNode() {
        self.quadNode = QuadNode(sceneView: sceneView, resetButton: resetButton, instructionLabel: instructionLabel)
        scene.rootNode.addChildNode(quadNode)
        scene.rootNode.addChildNode(dummyNode)
    }

    func setupSKScene() {
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
        skScene.delegate = self
        skScene.anchorPoint = CGPoint(x: 0, y: 0)
        skScene.isUserInteractionEnabled = true
    }

    func setupTableView() {
        // Initialize the child view controller
        tableViewController = TableViewController()

        // Add as a child view controller
        addChild(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMove(toParent: self)

        // Set the frame or constraints
        tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableViewController.view.widthAnchor.constraint(equalToConstant: 200),
            tableViewController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}
