//
//  LivenessAttemptsCountItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/31/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessAttemptsCountItem: CatalogItem {
    override init() {
        super.init()

        title = "Limit Liveness attempts count"
        itemDescription = "Liveness is limited to the number of retries."
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.attemptsCount = 2;
        }

        Face.service.startLiveness(
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
