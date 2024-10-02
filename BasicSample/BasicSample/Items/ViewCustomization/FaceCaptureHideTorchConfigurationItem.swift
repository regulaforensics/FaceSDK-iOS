//
//  FaceCaptureHideTorchConfigurationItem.swift
//  BasicSample
//
//  Created by Pavel Kondrashkov on 7/5/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureHideTorchConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "Hide flash button"
        itemDescription = "Hide flash button using default UI"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = FaceCaptureConfiguration {
            $0.isTorchButtonEnabled = false
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

