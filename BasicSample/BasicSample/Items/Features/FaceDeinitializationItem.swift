//
//  FaceDeinitializationItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 4.07.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import Foundation
import FaceSDK

final class FaceDeinitializationItem: CatalogItem {

    override init() {
        super.init()

        title = "Deinitialization SDK"
        itemDescription = "Deinitialization FaceSDK resources"
        category = .feature
    }

    override func onItemSelected(from viewController: UIViewController) {

        FaceSDK.service.deinitialize()

        if FaceSDK.service.isInitialized {
            print("FaceSDK deinitialized")
        }
    }
}
