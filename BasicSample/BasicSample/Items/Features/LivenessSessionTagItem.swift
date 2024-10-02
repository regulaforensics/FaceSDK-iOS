//
//  LivenessSessionTagItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 4.07.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import Foundation
import FaceSDK

final class LivenessSessionTagItem: CatalogItem {
    override init() {
        super.init()
        
        title = "Liveness Session Tag"
        itemDescription = "Setup session tag for liveness"
        category = .feature
    }
    
    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.tag = UUID().uuidString
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
