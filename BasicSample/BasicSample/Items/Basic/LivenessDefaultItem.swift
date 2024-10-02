//
//  LivenessDefaultItem.swift
//  BasicSample
//
//  Created by Pavel Kondrashkov on 5/20/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessDefaultItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness"
        itemDescription = "Detects if a person on camera is alive"
        category = .basic
    }

    override func onItemSelected(from viewController: UIViewController) {
        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
            },
            completion: nil
        )
    }
}
