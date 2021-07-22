//
//  LivenessHintAnimationItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/31/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessHintAnimationItem: CatalogItem {
    override init() {
        super.init()

        title = "Disable Liveness HintView animation"
        itemDescription = "Disables blinking HintView animation for Liveness."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.isHintAnimationEnabled = false
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
