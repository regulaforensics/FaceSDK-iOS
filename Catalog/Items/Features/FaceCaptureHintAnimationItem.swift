//
//  FaceCaptureHintAnimationItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/31/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureHintAnimationItem: CatalogItem {
    override init() {
        super.init()

        title = "Disable FaceCapture HintView animation"
        itemDescription = "Disables blinking HintView animation for FaceCapture."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = FaceCaptureConfiguration {
            $0.isHintAnimationEnabled = false
        }

        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            configuration: configuration,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil)
    }
}
