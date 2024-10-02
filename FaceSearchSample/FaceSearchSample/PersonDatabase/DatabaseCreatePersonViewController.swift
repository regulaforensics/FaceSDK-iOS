//
//  DatabaseCreatePersonViewController.swift
//  BasicSample
//
//  Created by Serge Rylko on 21.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class DatabaseCreatePersonViewController: UIViewController {

    @IBOutlet private weak var addImageButton: UIButton!
    @IBOutlet private weak var createPersonButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var surnameTextField: UITextField!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var imagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)
    private let database: PersonDatabase = FaceSDK.service.personDatabase
    
    private var images: [UIImage] = []
    private var name: String?
    private var surname: String?
    private let group: PersonDatabase.PersonGroup
    
    init(group: PersonDatabase.PersonGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Person in group"
        
        let button = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(didTapClearButton))
        navigationItem.setRightBarButton(button, animated: false)
        
        collectionView.register(PersonImageCell.self, forCellWithReuseIdentifier: PersonImageCell.reuseID)
    }
    
    //MARK: - Database
    private func createPerson() {
        showLoadingActivity()
        createPerson { [weak self] result in
            self?.hideLoadingActivity()
            switch result {
            case .success(let person):
                self?.handleSuccess(person: person)
            case .failure(let error):
                self?.handleFailure(error: error)
            }
        }
    }
    
    private func createPerson(completion: @escaping ((Result<PersonDatabase.Person, Error>) -> Void)) {
        guard let name = name, name.count > 0 else {
            completion(.failure(CreatePersonError.requiredNameParameterMissed))
            return
        }
        let metadata = ["surname": surname ?? ""]

        database.createPerson(name: name, metadata: metadata, groupIds: [group.itemId]) { [weak self] response in
            guard let self = self else { return }
            if let person = response.item {
                var error: Error?
                let group = DispatchGroup()
                for image in self.images {
                    guard let imageData = image.pngData() else { continue }
                    let upload = PersonDatabase.ImageUpload(imageData:imageData)
                    group.enter()
                    self.database.addPersonImage(personId: person.itemId, imageUpload: upload) { response in
                        error = response.error
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(person))
                    }
                }
            } else if let error = response.error {
                completion(.failure(error))
            }
        }
    }

    //MARK: Actions
    @IBAction private func didTapAddPersonImage(_ sender: Any) {
        imagePicker.presentPickerActions(from: view)
    }
    
    @IBAction private func didTapCreatePerson(_ sender: Any) {
        createPerson()
    }
    
    @objc private func didTapClearButton(_ sender: Any) {
        resetPersonData()
    }
    
    private func resetPersonData() {
        name = nil
        nameTextField.text = nil
        surname = nil
        surnameTextField.text = nil
        images = []
        collectionView.reloadData()
    }

    //MARK: - Dialogs
    private func handleSuccess(person: PersonDatabase.Person) {
        let message = "id: \(person.itemId) \nname: \(person.name) \nsurname: \(person.surname ?? "")"
        let action = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Person created.", message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func handleFailure(error: Error) {
        let message = "Error: \(error.localizedDescription)"
        let action = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Failed to add Person.", message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Loading states
    private func showLoadingActivity() {
        addImageButton.isEnabled = false
        createPersonButton.isEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        addImageButton.isEnabled = true
        createPersonButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension DatabaseCreatePersonViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            name = textField.text
        case surnameTextField:
            surname = textField.text
        default: break
        }
    }
}

extension DatabaseCreatePersonViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let divider = UIDevice.current.orientation.isPortrait ? 2.0 : 3.0
        let side = collectionView.bounds.width / divider
        let size = CGSize(width: side, height: side)
        return size
    }
}

extension DatabaseCreatePersonViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonImageCell.reuseID, for: indexPath) as? PersonImageCell else {
            fatalError("Unable to reuse cell")
        }
        
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}

extension DatabaseCreatePersonViewController: ImagePickerDelegate {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType) {
        images.append(image)
        collectionView.reloadData()
    }
}

private enum CreatePersonError: LocalizedError {
    case requiredNameParameterMissed
    
    var errorDescription: String? {
        "Person name is required"
    }
}
