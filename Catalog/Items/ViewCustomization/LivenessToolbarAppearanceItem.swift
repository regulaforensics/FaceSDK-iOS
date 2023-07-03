//
//  LivenessToolbarAppearanceItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/28/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessToolbarAppearanceItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness CameraToolbarView appearance"
        itemDescription = "UIAppearance usage example for CameraToolbarView."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let toolbarAppearance = CameraToolbarView.appearance(whenContainedInInstancesOf: [LivenessContentView.self])
        toolbarAppearance.backgroundColor = .windsor
        toolbarAppearance.setTintColor(.init(hex: "#84B1CB"), for: .front)

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

private extension LivenessToolbarAppearanceItem {
    /// Restorins original appearance.
    private func applyOriginalAppearance() {
        let toolbarAppearance = CameraToolbarView.appearance(whenContainedInInstancesOf: [LivenessContentView.self])
        toolbarAppearance.backgroundColor = .clear

        let toolbarButtonAppearance = UIButton.appearance(whenContainedInInstancesOf: [CameraToolbarView.self, LivenessContentView.self])
        toolbarButtonAppearance.backgroundColor = nil
        toolbarButtonAppearance.tintColor = .white
    }
}
