//
//  LivenessToolbarCustomButtonItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/28/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessToolbarCustomButtonItem: CatalogItem {
    final class Toolbar: CameraToolbarView {
        let customCloseButton = UIButton()

        override var torchButton: UIButton? { return nil }
        override var switchCameraButton: UIButton? { return nil }
        override var closeButton: UIButton? { return customCloseButton }

        override init(frame: CGRect) {
            super.init(frame: frame)
            customCloseButton.backgroundColor = .windsor
            customCloseButton.setTitle("CLOSE", for: .normal)
            customCloseButton.titleLabel?.font = UIFont(name: "AmericanTypewriter", size: 30)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setupConstraints() {
            if let closeButton = closeButton {
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor),
                    closeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    closeButton.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
                ])
            }
        }
    }

    override init() {
        super.init()

        title = "Liveness CameraToolbarView custom close button"
        itemDescription = "Overriden CameraToolbarView class."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
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
