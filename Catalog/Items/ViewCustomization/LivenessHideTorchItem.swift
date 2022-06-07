//
//  LivenessHideTorchItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/19/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessHideTorchItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness CameraToolbarView hide torch button"
        itemDescription = "Subclassing API usage example."
        category = .viewCustomization
    }

    final class Toolbar: CameraToolbarView {
        override var torchButton: UIButton? { return nil }
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.cameraPosition = .back
            $0.isCameraSwitchButtonEnabled = true
            $0.registerClass(Toolbar.self, forBaseClass: CameraToolbarView.self)
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

