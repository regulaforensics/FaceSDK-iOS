//
//  LivenessHideTorchConfigurationItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 7/5/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessHideTorchConfigurationItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness CameraToolbarView hide torch button"
        itemDescription = "LivenessConfiguration usage example."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.cameraPosition = .back
            $0.isCameraSwitchButtonEnabled = true
            $0.isTorchButtonEnabled = false
        }

        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            configuration: configuration,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
            },
            completion: nil
        )
    }
}

