//
//  ImagePicker.swift
//  Catalog
//
//  Created by Serge Rylko on 26.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import UIKit

protocol ImagePickerDelegate: AnyObject {
    func didPickImage(delegate: ImagePicker, image: UIImage)
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

    func presentDefaultActions(from sourceView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
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
        
        delegate.didPickImage(delegate: self, image: image)
        presenter.dismiss(animated: true)
    }
}
