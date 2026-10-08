//
//  LivenessUIConfiguration.swift
//  BasicSample
//
//  Created by Dmitry Evglevsky on 9.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK

final class LivenessUIConfigurationItem: CatalogItem {

    private enum Colors {
        static let title = UIColor(hex: "#469597")
        static let message = UIColor(hex: "#5BA199")
        static let background = UIColor(hex: "#E5E3E4")
        static let image = UIColor(hex: "#DDBEAA")
        static let lightGray = UIColor(hex: "#BBC6C8")
        static let text = UIColor(hex: "#663399")
        static let button = UIColor(hex: "#E5E3E4")
    }

    private enum Images {
        static var close: UIImage { UIImage(named: "close")! }
        static var success: UIImage { UIImage(named: "success")! }
    }

    private enum Fonts {
        static let title = UIFont(name: "Roboto-Italic", size: 35)!
        static let subtitle = UIFont(name: "Roboto-Italic", size: 30)!
        static let message = UIFont(name: "Roboto-Black", size: 25)!
        static let button = UIFont(name: "Roboto-Black", size: 40)!
    }

    override init() {
        super.init()

        title = "Liveness Screen Configuration"
        itemDescription = "Interface customization"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let interfaceConfiguration = UIConfiguration {
            // Onboarding
            $0.setColor(Colors.background, forItem: .OnboardingScreenBackground)
            $0.setColor(Colors.message, forItem: .OnboardingScreenStartButtonBackground)
            $0.setColor(Colors.background, forItem: .OnboardingScreenStartButtonTitle)
            $0.setColor(Colors.title, forItem: .OnboardingScreenTitleLabelText)
            $0.setColor(Colors.lightGray, forItem: .OnboardingScreenSubtitleLabelText)
            $0.setColor(Colors.message, forItem: .OnboardingScreenMessageLabelsText)

            $0.setImage(Images.close, forItem: .onboardingScreenCloseButton)
            if #available(iOS 16.0, *) {
                $0.setImage(UIImage(systemName: "sun.max.trianglebadge.exclamationmark")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .onboardingScreenIllumination)
                $0.setImage(UIImage(systemName: "eyeglasses")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .onboardingScreenAccessories)
                $0.setImage(UIImage(systemName: "camera.viewfinder")!.withTintColor(.black, renderingMode: .alwaysOriginal),
                            forItem: .onboardingScreenCameraLevel)
            } else {
                // Use your image assets.
            }
            $0.setFont(Fonts.title, forItem: .onboardingScreenTitleLabel)
            $0.setFont(Fonts.subtitle, forItem: .onboardingScreenSubtitleLabel)
            $0.setFont(Fonts.message, forItem: .onboardingScreenMessageLabels)
            $0.setFont(Fonts.button, forItem: .onboardingScreenStartButton)

            // Camera
            $0.setColor(Colors.title, forItem: .CameraScreenFrontHintLabelText)
            $0.setColor(Colors.background, forItem: .CameraScreenFrontHintLabelBackground)
            $0.setColor(Colors.title, forItem: .CameraScreenLightToolbarTint)

            $0.setColor(Colors.lightGray, forItem: .CameraScreenSectorActive)
            $0.setColor(Colors.title, forItem: .CameraScreenSectorTarget)
            $0.setColor(Colors.lightGray, forItem: .CameraScreenStrokeActive)
            $0.setColor(Colors.image, forItem: .CameraScreenStrokeNormal)

            $0.setImage(Images.close, forItem: .cameraScreenCloseButton)

            $0.setFont(Fonts.message, forItem: .cameraScreenHintLabel)

            $0.setColor(Colors.lightGray, forItem: .ProcessingScreenBackground)
            $0.setColor(Colors.title, forItem: .ProcessingScreenTitleLabel)
            $0.setColor(Colors.message, forItem: .ProcessingScreenProgress)
            $0.setFont(Fonts.subtitle, forItem: .processingScreenLabel)

            // Retry screen
            $0.setImage(Images.close, forItem: .retryScreenCloseButton)
            if #available(iOS 16.0, *) {
                let retryEnvImage = UIImage(systemName: "sun.max.trianglebadge.exclamationmark")!
                    .withTintColor(.black, renderingMode: .alwaysOriginal)
                $0.setImage(retryEnvImage, forItem: .retryScreenHintEnvironment)
                let retryHintImage = UIImage(systemName: "face.smiling")!
                    .withTintColor(.black, renderingMode: .alwaysOriginal)
                $0.setImage(retryHintImage, forItem: .retryScreenHintSubject)
            } else {
                // Use your image assets.
            }
            $0.setColor(Colors.background, forItem: .RetryScreenBackground)
            $0.setColor(Colors.title, forItem: .RetryScreenTitleLabelText)
            $0.setColor(Colors.lightGray, forItem: .RetryScreenSubtitleLabelText)
            $0.setColor(Colors.message, forItem: .RetryScreenHintLabelsText)
            $0.setColor(Colors.title, forItem: .RetryScreenRetryButtonBackground)
            $0.setColor(Colors.image, forItem: .RetryScreenRetryButtonTitle)

            $0.setFont(Fonts.title, forItem: .retryScreenTitleLabel)
            $0.setFont(Fonts.subtitle, forItem: .retryScreenSubtitleLabel)
            $0.setFont(Fonts.message, forItem: .retryScreenHintLabels)
            $0.setFont(Fonts.button, forItem: .retryScreenRetryButton)

            // Success screen
            $0.setImage(Images.success, forItem: .successScreenImage)
            $0.setColor(Colors.lightGray, forItem: .SuccessScreenBackground)
        }

        
        FaceSDK.service.customization.configuration = interfaceConfiguration
        
        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                FaceSDK.service.customization.configuration = nil
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
            },
            completion: nil)
    }
}
