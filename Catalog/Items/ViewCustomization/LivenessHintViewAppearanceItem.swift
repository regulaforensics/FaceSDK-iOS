//
//  LivenessHintViewAppearanceItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/19/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessHintViewAppearanceItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness HintView appearance"
        itemDescription = "UIAppearance usage example for HintView."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let hintViewAppearance = HintView.appearance(whenContainedInInstancesOf: [LivenessContentView.self])
        hintViewAppearance.cornerRadius = 20
        hintViewAppearance.setBackgroundColor(.yellow, for: .front)
        hintViewAppearance.setTextColor(.black, for: .front)

        let hintLabelAppearance = UILabel.appearance(whenContainedInInstancesOf: [HintView.self, LivenessContentView.self])
        hintLabelAppearance.font = UIFont(name: "ChalkboardSE-Regular", size: 40)

        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)

                // This call is only for demo.
                // Restoring original appearance so other examples are not affected.
                self.applyOriginalAppearance()
            },
            completion: nil
        )
    }
}

private extension LivenessHintViewAppearanceItem {
    /// Restorins original appearance of the HintView.
    private func applyOriginalAppearance() {
        let hintViewAppearance = HintView.appearance(whenContainedInInstancesOf: [LivenessContentView.self])
        hintViewAppearance.cornerRadius = 8
        hintViewAppearance.setBackgroundColor(.black, for: .front)
        hintViewAppearance.setTextColor(.white, for: .front)

        let hintLabelAppearance = UILabel.appearance(whenContainedInInstancesOf: [HintView.self, LivenessContentView.self])
        hintLabelAppearance.font = .systemFont(ofSize: 30)
    }
}
