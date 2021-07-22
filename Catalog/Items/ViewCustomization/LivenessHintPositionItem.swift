//
//  LivenessHintPositionItem.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/28/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class LivenessHintPositionItem: CatalogItem {
    final class ContentView: LivenessContentView {
        override func setupConstraints() {
            // Overrides layout with constraints.
            toolbarView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                toolbarView.leadingAnchor.constraint(equalTo: leadingAnchor),
                toolbarView.trailingAnchor.constraint(equalTo: trailingAnchor),
                toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            hintView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hintView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                hintView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -70),
            ])
        }
    }

    override init() {
        super.init()

        title = "Liveness HintView position"
        itemDescription = "Overriden ContenView layout. Changed HintView position."
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.registerClass(ContentView.self, forBaseClass: LivenessContentView.self)
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
