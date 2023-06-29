//
//  LivenessUIConfiguration.swift
//  Catalog
//
//  Created by Dmitry Evglevsky on 9.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK

final class LivenessUIConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness UI Configuration"
        itemDescription = "Interface customization."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let messageFont = UIFont(name: "Copperplate", size: 18)!
        let titleFont = UIFont(name: "Copperplate", size: 26)!
        
        let interfaceConfiguration = UIConfiguration {
            // Onboarding screen colors.
            $0.setColor(.systemYellow, forItem: .OnboardingScreenBackground)
            $0.setColor(.black, forItem: .OnboardingScreenStartButtonBackground)
            
            // Onboarding screen fonts.
            $0.setFont(messageFont, forItem: .OnboardingScreenMessageLabel)
            $0.setFont(titleFont, forItem: .OnboardingScreenTitleLabel)
            $0.setFont(titleFont, forItem: .OnboardingScreenStartButton)
            
            // Onboarding screen images.
            if #available(iOS 16.0, *) {
                $0.setImage(UIImage(systemName: "sun.max.trianglebadge.exclamationmark")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .OnboardingScreenIllumination)
                $0.setImage(UIImage(systemName: "eyeglasses")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .OnboardingScreenAccessories)
                $0.setImage(UIImage(systemName: "camera.viewfinder")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .OnboardingScreenCameraLevel)
            } else {
                // Use your image assets.
            }
            
            // Camera screen colors.
            $0.setColor(.systemYellow, forItem: .CameraScreenStrokeActive)
            $0.setColor(.systemYellow, forItem: .CameraScreenStrokeNormal)
            $0.setColor(.systemYellow, forItem: .CameraScreenSectorActive)
            $0.setColor(.systemYellow.withAlphaComponent(0.35), forItem: .CameraScreenSectorTarget)
            $0.setColor(.systemYellow, forItem: .CameraScreenFrontHintLabelBackground)
            $0.setColor(.black, forItem: .CameraScreenFrontHintLabelText)
            
            // Camera screen fonts.
            $0.setFont(titleFont, forItem: .CameraScreenHintLabel)
            
            // Processing screen colors.
            $0.setColor(.systemYellow, forItem: .ProcessingScreenBackground)
            $0.setColor(.black, forItem: .ProcessingScreenProgress)
            $0.setColor(.black, forItem: .ProcessingScreenTitleLabel)
            
            // Processing screen fonts.
            $0.setFont(titleFont, forItem: .ProcessingScreenLabel)
            
            // Retry screen colors.
            $0.setColor(.systemYellow, forItem: .RetryScreenBackground)
            $0.setColor(.black, forItem: .RetryScreenRetryButtonBackground)
            
            // Retry screen fonts.
            $0.setFont(messageFont, forItem: .RetryScreenHintLabels)
            $0.setFont(titleFont, forItem: .RetryScreenTitleLabel)
            $0.setFont(titleFont, forItem: .RetryScreenRetryButton)
            
            // Retry screen images.
            if #available(iOS 16.0, *) {
                $0.setImage(UIImage(systemName: "sun.max.trianglebadge.exclamationmark")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .RetryScreenHintEnvironment)
                $0.setImage(UIImage(systemName: "face.smiling")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .RetryScreenHintSubject)
            } else {
                // Use your image assets.
            }
            
            // Success screen colors.
            $0.setColor(.systemYellow, forItem: .SuccessScreenBackground)
            
            // Success screen images.
            if #available(iOS 16.0, *) {
                $0.setImage(UIImage(systemName: "checkmark.circle")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .SuccessScreenImage)
            } else {
                // Use your image assets.
            }
        }
        FaceSDK.service.customization.configuration = interfaceConfiguration
        
        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
            },
            completion: nil)
    }
    
    deinit {
        FaceSDK.service.customization.configuration = nil
    }
}
