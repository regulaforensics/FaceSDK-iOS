//
//  LivenessSkipOnboardingAndSuccessItem.swift
//  BasicSample
//
//  Created by Dmitry Evglevsky on 25.01.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK

final class LivenessSkipOnboardingAndSuccessItem: CatalogItem {
    override init() {
        super.init()

        title = "Skip Onboarding & Success steps"
        itemDescription = "Liveness will not show onboarding & success screens"
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.stepSkippingMask = [.onboarding, .success]
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
