//
//  FaceCaptureUIConfiguration.swift
//  BasicSample
//
//  Created by Dmitry Evglevsky on 29.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureUIConfigurationItem: CatalogItem {

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
        static var swap: UIImage { UIImage(named: "swap_camera")! }
        static var torch: UIImage { UIImage(named: "flash")! }
    }

    private enum Fonts {
//        static let title = UIFont(name: "Roboto-Italic", size: 35)!
//        static let subtitle = UIFont(name: "Roboto-Italic", size: 30)!
        static let message = UIFont(name: "Roboto-Black", size: 25)!
//        static let button = UIFont(name: "Roboto-Black", size: 40)!
    }

    override init() {
        super.init()

        title = "Face Capture Configuration"
        itemDescription = "Interface customization"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {

        let interfaceConfiguration = UIConfiguration(builderBlock: {
            $0.setColor(Colors.title, forItem: CustomizationColor.CameraScreenFrontHintLabelText)
            $0.setColor(Colors.background, forItem: CustomizationColor.CameraScreenFrontHintLabelBackground)

            $0.setColor(Colors.title, forItem: .CameraScreenBackHintLabelText)
            $0.setColor(Colors.background, forItem: .CameraScreenBackHintLabelBackground)

            $0.setColor(Colors.title, forItem: .CameraScreenLightToolbarTint)
            $0.setColor(Colors.lightGray, forItem: .CameraScreenDarkToolbarTint)

            $0.setColor(Colors.lightGray, forItem: .CameraScreenStrokeActive)
            $0.setColor(Colors.image, forItem: .CameraScreenStrokeNormal)

            $0.setImage(Images.close, forItem: .CameraScreenCloseButton)
            $0.setImage(Images.swap, forItem: .CameraScreenSwitchButton)
            $0.setImage(Images.torch, forItem: .CameraScreenLightOnButton)
            $0.setImage(Images.torch, forItem: .CameraScreenLightOffButton)

            $0.setFont(Fonts.message, forItem: .CameraScreenHintLabel)
            $0.setFont(Fonts.message, forItem: .ProcessingScreenLabel)
        })
        FaceSDK.service.customization.configuration = interfaceConfiguration

        let faceCaptureConfig = FaceCaptureConfiguration {
            $0.isCameraSwitchButtonEnabled = true
        }
        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            configuration: faceCaptureConfig,
            onCapture: { [weak self, weak viewController] response in
                FaceSDK.service.customization.configuration = nil
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil)
    }
}

