//
//  FaceCaptureDefaultItem.swift
//  BasicSample
//
//  Created by Pavel Kondrashkov on 5/20/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureDefaultItem: CatalogItem {
    override init() {
        super.init()

        title = "FaceCapture"
        itemDescription = "Automaticlly captures face photo"
        category = .basic
    }

    override func onItemSelected(from viewController: UIViewController) {
        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil)
    }
}

