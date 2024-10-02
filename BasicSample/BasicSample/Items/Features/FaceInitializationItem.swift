//
//  FaceInitializationItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 4.07.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import Foundation
import FaceSDK

final class FaceInitializationItem: CatalogItem {
    override init() {
        super.init()
        
        title = "Initialization SDK"
        itemDescription = "Initialization FaceSDK resources"
        category = .feature
    }
    
    override func onItemSelected(from viewController: UIViewController) {
        
        FaceSDK.service.initialize { success, error in
            if success {
                print("FaceSDK initialized")
            } else if let error = error {
                print("FaceSDK initialization failure: \(error.localizedDescription)")
            }
        }
    }
}
