//
//  FaceCaptureBackgroundColor.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/28/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureBackgroundColor: CatalogItem {
    override init() {
        super.init()

        title = "Face Capture background color"
        itemDescription = "Changes default background color of the overlay."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let appearance = FaceCaptureContentView.appearance()
        appearance.setBackgroundColor(.init(hex: "#FEE9FF"), for: .front)
        appearance.setBackgroundColor(.init(hex: "#6F5685"), for: .rear)

        let configuration = FaceCaptureConfiguration {
            $0.cameraSwitchEnabled = true
        }

        Face.service.presentCaptureViewController(
            from: viewController,
            animated: true,
            configuration: configuration,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)

                // This call is only for demo.
                // Restoring original appearance so other examples are not affected.
                self.applyOriginalAppearance()
            },
            completion: nil)
    }
}

extension FaceCaptureBackgroundColor {
    /// Restorins original appearance.
    private func applyOriginalAppearance() {
        let appearance = FaceCaptureContentView.appearance()
        appearance.setBackgroundColor(.white, for: .front)
        appearance.setBackgroundColor(.black, for: .rear)
    }
}
