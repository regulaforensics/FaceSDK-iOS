//
//  LivenessHideNotificationItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 13.09.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import FaceSDK

final class FaceCaptureHideNotificationItem: CatalogItem {

    private class CustomCaptureContentView: FaceCaptureContentView {
        override init(frame: CGRect) {
            super.init(frame: frame)

            hintView.setBackgroundColor(.clear, for: .rear)
            hintView.setBackgroundColor(.clear, for: .front)
            hintView.setTextColor(.clear, for: .rear)
            hintView.setTextColor(.clear, for: .front)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    override init() {
        super.init()

        title = "Hide notification text view"
        itemDescription = "Hide notification text view using default UI"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = FaceCaptureConfiguration {
            $0.isCameraSwitchButtonEnabled = true
            $0.registerClass(CustomCaptureContentView.self, forBaseClass: FaceCaptureContentView.self)
        }
        FaceSDK.service.presentFaceCaptureViewController(
            from: viewController,
            animated: true,
            configuration: configuration,
            onCapture: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showFaceCaptureResult(response, from: viewController)
            },
            completion: nil
        )
    }
}

