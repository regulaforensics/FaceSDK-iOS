//
//  LivenessLogoItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/28/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessLogoItem: CatalogItem {
    override init() {
        super.init()

        title = "Your logo example"
        itemDescription = "Subclass ContentView and add your subviews."
        category = .viewCustomization
    }

    final class ContentView: LivenessContentView {
        lazy var logoImageView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(named: "logo")
            return view
        }()

        override func setupConstraints() {
            super.setupConstraints()
            addSubview(logoImageView)
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                logoImageView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: -20),
                logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 1 / 1.88),
                logoImageView.widthAnchor.constraint(equalToConstant: 150),
            ])
        }
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.registerClass(ContentView.self, forBaseClass: LivenessContentView.self)
        }

        Face.service.startLiveness(
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
