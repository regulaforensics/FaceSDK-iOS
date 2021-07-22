//
//  LivenessCameraSwitchItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/18/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessCameraSwitchItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness camera switch"
        itemDescription = "Enables front / back camera switch."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.cameraSwitchEnabled = true
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
