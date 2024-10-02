//
//  VideoUploadingCompletionItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 9.07.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import Foundation

import FaceSDK

final class VideoUploadingCompletionItem: CatalogItem {
    override init() {
        super.init()

        title = "Video completion about uploading liveness video to service"
        itemDescription = "Video completion"
        category = .other
    }

    override func onItemSelected(from viewController: UIViewController) {
        let service = FaceSDK.service
        service.videoUploadingDelegate = self

        service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak service, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
                service?.videoUploadingDelegate = nil
            },
            completion: nil
        )
    }
}

extension VideoUploadingCompletionItem: VideoUploadingDelegate {
    func videoUploading(forTransactionId transactionId: String, didFinishedWithSuccess success: Bool) {
        print("transactionId: \(transactionId), success: \(success)")
    }
}
