//
//  ImagePicker.swift
//  BasicSample
//
//  Created by Serge Rylko on 26.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import UIKit
import FaceSDK

protocol ImagePickerDelegate: AnyObject {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType)
}

final class ImagePicker: NSObject, UINavigationControllerDelegate {

    private let pickerController = UIImagePickerController()
    private unowned let presenter: UIViewController
    private unowned let delegate: ImagePickerDelegate

    init(presenter: UIViewController, delegate: ImagePickerDelegate) {
        self.presenter = presenter
        self.delegate = delegate
        super.init()
        setup()
    }

    private func setup() {
        pickerController.delegate = self
        pickerController.allowsEditing = true
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presenter.present(self.pickerController, animated: true)
        }
    }

    private func actionSDK(title: String) -> UIAlertAction? {
        guard FaceSDK.service.isInitialized else { return nil }
        let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let self = self else { return }
            FaceSDK.service.presentFaceCaptureViewController(from: self.presenter, animated: true) { response in
                if let image = response.image?.image {
                    self.delegate.didPickImage(delegate: self, image: image, sourceType: .camera)
                    self.presenter.dismiss(animated: true)
                }
            }
        }
        return action
    }

    func presentPickerActions(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = actionSDK(title: "Regula FaceCaptureUI") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Gallery") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .camera, title: "Camera Shot") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        presenter.present(alertController, animated: true)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        delegate.didPickImage(delegate: self, image: image, sourceType: .photoLibrary)
        presenter.dismiss(animated: true)
    }
}
