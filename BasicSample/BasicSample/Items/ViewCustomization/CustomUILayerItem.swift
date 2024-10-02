//
//  CustomUILayerItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 23.09.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import FaceSDK

final class CustomUILayerItem: CatalogItem {

    override init() {
        super.init()

        title = "Custom UI layer"
        itemDescription = "Custom labels, images and buttons to the camera screen"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.isCloseButtonEnabled = false
        }
        FaceSDK.service.customization.customUILayerJSON = customLayer()
        FaceSDK.service.customization.actionDelegate = self
        FaceSDK.service.livenessDelegate = self

        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            configuration: configuration,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
                FaceSDK.service.customization.customUILayerJSON = nil
            },
            completion: nil
        )
    }

    private func customLayer() -> [String: Any]? {
        guard
            let jsonURL = Bundle.main.url(forResource: "layer.json", withExtension: nil),
            let data = try? Data(contentsOf: jsonURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json
    }

    private func updateCustomLayer() {
        guard let layerJSON = customLayer() else { return }
        FaceSDK.service.customization.customUILayerJSON = layerJSON
    }

    @objc private func animateCustomView() {
        guard let customLayerJSON = customLayer() else { return }
        let updatedJSON = JSONHelper.updateJSON(json: customLayerJSON, 
                                                objectKey: "image",
                                                newField: "alpha",
                                                newFieldValue: 0)

        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.autoreverse, .repeat]) {
            FaceSDK.service.customization.customUILayerJSON = updatedJSON
        }
    }
}

extension CustomUILayerItem: FaceSDK.CustomizationActionDelegate {
    func onFaceCustomButtonTapped(withTag tag: Int) {
        guard tag == FaceSDK.CustomButtonTag.close.rawValue else { return }
        print("Custom close button tapped")
    }
}

extension CustomUILayerItem: LivenessDelegate {
    func processStatusChanged(_ status: LivenessProcessStatus, result: LivenessResponse?) {
        if status == .newSession {
            animateCustomView()
        }
    }
}
