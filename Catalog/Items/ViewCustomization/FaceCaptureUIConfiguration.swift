//
//  FaceCaptureUIConfiguration.swift
//  Catalog
//
//  Created by Dmitry Evglevsky on 29.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureUIConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "FaceCapture UI Configuration"
        itemDescription = "Interface customization."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let titleFont = UIFont(name: "Copperplate", size: 26)!
        
        let interfaceConfiguration = UIConfiguration {
            // Camera screen colors.
            $0.setColor(.systemYellow, forItem: .CameraScreenStrokeActive)
            $0.setColor(.systemYellow, forItem: .CameraScreenStrokeNormal)
            $0.setColor(.systemYellow, forItem: .CameraScreenFrontHintLabelBackground)
            $0.setColor(.black, forItem: .CameraScreenFrontHintLabelText)
            
            // Camera screen fonts.
            $0.setFont(titleFont, forItem: .CameraScreenHintLabel)
        }
        FaceSDK.service.customization.configuration = interfaceConfiguration
        
        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil)
    }
    
    deinit {
        FaceSDK.service.customization.configuration = nil
    }
}

