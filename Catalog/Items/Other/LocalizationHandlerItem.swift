//
//  LocalizationHandlerItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/19/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LocalizationHandlerItem: CatalogItem {
    override init() {
        super.init()

        title = "Custom localization"
        itemDescription = "Localization hook example."
        category = .other
    }

    override func onItemSelected(from viewController: UIViewController) {
        
        Face.service.localizationHandler = { localizationKey in
            // This will look up localization in `CustomLocalization.strings`.
            let result = NSLocalizedString(localizationKey, tableName: "CustomLocalization", comment: "")

            // Localization found in CustomLocalization.
            if result != localizationKey {
                return result
            }

            // Custom key lookup.
            if localizationKey == "faceSDKMoveCloser" {
                return "Handler: Move Closer"
            }

            // Fallback to default localization provided by SDK
            return nil
        }

        Face.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
                Face.service.localizationHandler = nil
            },
            completion: nil
        )
    }
}

