//
//  CatalogItem+Routing.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/19/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

extension CatalogItem {
    func showLivenessResult(_ result: LivenessResponse, from viewController: UIViewController) {
        if case LivenessError.cancelled? = result.error { return }

        let title = result.liveness == .passed ? "Passed" : "Failed"
        let message = result.error?.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }

    func showFaceCaptureResult(_ result: FaceCaptureResponse, from viewController: UIViewController) {
        if case FaceCaptureError.cancelled? = result.error { return }
        let resultViewController = result.image
            .map { $0.image }
            .map { ImagesPreviewViewController(images: [$0]) }
        
        if let resultViewController = resultViewController {
            viewController.present(resultViewController, animated: true, completion: nil)
        }
    }
}
