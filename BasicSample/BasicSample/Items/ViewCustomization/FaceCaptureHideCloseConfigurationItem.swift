//
//  FaceCaptureHideCloseConfigurationItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 13.09.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureCloseTorchConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "Hide close button"
        itemDescription = "Hide close button using default UI"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = FaceCaptureConfiguration {
            $0.isCloseButtonEnabled = false
        }
        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            configuration: configuration,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil
        )
    }
}


