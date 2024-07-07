//
//  SceneReconstructionViewController+Buttons.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/13/24.
//

import UIKit

extension SceneReconstructionViewController {

    func setupRecordButton() {
        recordButton = UIButton(type: .system)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("", for: .normal)
        recordButton.backgroundColor = .red
        recordButton.tintColor = .white
        recordButton.layer.cornerRadius = 25
        recordButton.setTitle("START", for: .normal)

        // Add the button to the view
        view.addSubview(recordButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            recordButton.widthAnchor.constraint(equalToConstant: 100),
            recordButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add action for the button
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        provideHapticFeedback()
    }

    @objc func recordButtonTapped() {
        updateIsRecording(_isRecording: !isRecording)
    }
    
    // Provide haptic feedback on user interactions
    func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func setupShutterButton() {
        // Create the shutter button
        let shutterButton = UIButton(type: .system)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        //shutterButton.setTitle("", for: .normal)
        //shutterButton.backgroundColor = .systemBlue
        //shutterButton.tintColor = .white
        shutterButton.layer.cornerRadius = 25
        
        // Set the image for the button
            if let shutterImage = UIImage(named: "camera") {
                let orignalImage = shutterImage.withRenderingMode(.alwaysOriginal)
                shutterButton.setImage(orignalImage, for: .normal)
                shutterButton.imageEdgeInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            }

        // Add the button to the view
        view.addSubview(shutterButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70)
        ])

        // Add action for the button
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
    }

    @objc func shutterButtonTapped() {
        session.pause()
        sceneView.scene.rootNode.isHidden = true

        guard let frame = session.currentFrame else { return }
        guard let pov = sceneView.pointOfView else { return }
        let image = sceneView.snapshot()
        let rootNode = sceneView.scene.rootNode

        if let navigationController {
            let nextVC = DrawRulersViewController(
                viewSnapshot: image,
                pov: pov,
                frame: frame,
                root: rootNode
            )
            navigationController.pushViewController(nextVC, animated: false)
        }
    }

}
