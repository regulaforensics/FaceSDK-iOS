//
//  LivenessToolbarCustomColors.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 6/22/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessToolbarCustomColors: CatalogItem {
    final class Toolbar: CameraToolbarView {
        override func updateState(_ state: CameraToolbarViewState) {
            switch state {
            case .front:
                self.backgroundColor = .windsor
                self.torchButton?.tintColor = .white
                self.switchCameraButton?.tintColor = .white
                self.closeButton?.tintColor = .white
            case .rear:
                self.backgroundColor = .white
                self.torchButton?.tintColor = .windsor
                self.switchCameraButton?.tintColor = .windsor
                self.closeButton?.tintColor = .windsor
            @unknown default:
                fatalError("Unexpected state")
            }
        }
    }

    override init() {
        super.init()

        title = "Liveness CameraToolbarView custom colors"
        itemDescription = "Overriden CameraToolbarView class reacts to Camera state changes."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.isCameraSwitchButtonEnabled = true
            $0.registerClass(Toolbar.self, forBaseClass: CameraToolbarView.self)
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
