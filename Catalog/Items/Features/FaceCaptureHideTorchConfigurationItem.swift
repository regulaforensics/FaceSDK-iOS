//
//  FaceCaptureHideTorchConfigurationItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 7/5/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureHideTorchConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "FaceCapture CameraToolbarView hide torch button"
        itemDescription = "FaceCaptureConfiguration usage example."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = FaceCaptureConfiguration {
            $0.cameraPosition = .back
            $0.isCameraSwitchButtonEnabled = true
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

