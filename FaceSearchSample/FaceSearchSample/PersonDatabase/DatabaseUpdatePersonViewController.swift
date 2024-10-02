//
//  DatabaseUpdatePersonViewController.swift
//  BasicSample
//
//  Created by Serge Rylko on 23.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class DatabaseUpdatePersonViewController: UIViewController {
    
    @IBOutlet private weak var addImageButton: UIButton!
    @IBOutlet private weak var updatePersonButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var surnameTextField: UITextField!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var imagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)
    private let database: PersonDatabase = FaceSDK.service.personDatabase
    
    private var pickedImages: [UIImage] = []
    private var personImages: [PersonDatabase.PersonImage] = []
    private var personImagesToRemove: [PersonDatabase.PersonImage] = []
    private var name: String?
    private var surname: String?
    private let person: PersonDatabase.Person
    
    init(person: PersonDatabase.Person) {
        self.person = person
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Update Person"
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(didTapResetButton))
        navigationItem.setRightBarButton(resetButton, animated: false)
        
        collectionView.register(PersonImageCell.self, forCellWithReuseIdentifier: PersonImageCell.reuseID)
        collectionView.register(.init(nibName: "UpdatePersonCell", bundle: .main), forCellWithReuseIdentifier: "UpdatePersonCell")
        collectionView.register(SearchPersonHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchPersonHeader.reuseID)
        
        loadPersonData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Database
    private func loadPersonData() {
        setPersonData()
        
        loadingIndicator.startAnimating()
        database.getPersonImages(personId: person.itemId) { response in
            self.loadingIndicator.stopAnimating()
            if let personImages = response.items {
                self.personImages = personImages
                self.resetPersonData()
            } else if let error = response.error {
                self.handleFailure(error: error)
            }
        }
    }
    
    private func updatePerson() {
        loadingIndicator.startAnimating()
        updatePersonData { [weak self] result in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()
            switch result {
            case .success(let statuses):
                self.loadPersonData()
                self.handleSuccess(statuses: statuses)
            case .failure(let error):
                self.handleFailure(error: error)
            }
        }
    }
    
    private func updatePersonData(completion: @escaping ((Result<[String], UpdatePersonError>) -> Void)) {
        let personUpdateNeeded = (name != nil && name != person.name) || (surname != nil && surname != person.surname)
        let addingImagesNeeded = !pickedImages.isEmpty
        let removingImagesNeeded = !personImagesToRemove.isEmpty
        
        guard personUpdateNeeded || addingImagesNeeded || removingImagesNeeded else {
            completion(.failure(.updateSkipped))
            return
        }
        
        let group = DispatchGroup()
        var statuses : [String] = []
        var errors: [Error] = []
        
        if personUpdateNeeded {
            group.enter()
            updatePerson { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    let status = "Person fields updated :\(self.person.name), \(self.person.surname ?? ""): \(success)"
                    statuses.append(status)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
            
        }
        if removingImagesNeeded {
            group.enter()
            removePersonImages { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    let status = "Person images removed: \(self.personImagesToRemove.count): \(success)"
                    statuses.append(status)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        if addingImagesNeeded {
            group.enter()
            addPersonImages { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    let status = "Person images added: \(self.pickedImages.count): \(success)"
                    statuses.append(status)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                completion(.failure(.personDataUpdateFailed(errors: errors)))
            } else {
                completion(.success(statuses))
            }
        }
    }
    
    private func updatePerson(completion: @escaping ((Result<Bool, Error>) -> Void)) {
        var updateRequired = false
        if let name = name, person.name != name, !name.isEmpty {
            person.name = name
            updateRequired = true
        }
        if let surname, person.surname != surname, !surname.isEmpty {
            person.surname = surname
            updateRequired = true
        }
        
        if !updateRequired {
            completion(.success(true))
        } else {
            database.updatePerson(person: person) { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    private func addPersonImages(completion: @escaping (Result<Bool, Error>) -> Void) {
        let group = DispatchGroup()
        var error: Error?
        var result = false
        
        for image in pickedImages {
            guard let imageData = image.pngData() else { continue }
            let upload = PersonDatabase.ImageUpload(imageData:imageData)
            group.enter()
            
            database.addPersonImage(personId: person.itemId, imageUpload: upload) { response in
                result = response.item != nil
                error = response.error
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }
    
    private func removePersonImages(completion: @escaping (Result<Bool, Error>) -> Void) {
        let group = DispatchGroup()
        var error: Error?
        var result = false
        
        for personImage in personImagesToRemove {
            group.enter()
            database.deletePersonImage(personId: person.itemId, imageId: personImage.itemId) { response in
                result = response.success
                error = response.error
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(result))
            }
        }
    }
    
    private func setPersonData() {
        nameTextField.text = person.name
        surnameTextField.text = person.surname
        pickedImages = []
        collectionView.reloadData()
    }
    
    private func resetPersonData() {
        name = nil
        surname = nil
        personImagesToRemove = []
        pickedImages = []
        setPersonData()
    }
    
    //MARK: - Dialogs
    private func handleSuccess(statuses: [String]) {
        let message = statuses.joined(separator: "\n")
        let action = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Person updated.", message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func handleFailure(error: Error) {
        let message = "Error: \(error.localizedDescription)"
        let action = UIAlertAction(title: "OK", style: .cancel)
        let alert = UIAlertController(title: "Failed to update Person.", message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //MARK: - Actions
    @IBAction private func didTapAddPersonImage(_ sender: Any) {
        imagePicker.presentPickerActions(from: view)
    }
    
    @IBAction private func didTapUpdatePerson(_ sender: Any) {
        updatePerson()
    }
    
    @objc private func didTapResetButton(_ sender: Any) {
        resetPersonData()
    }
    
    //MARK: - Loading states
    private func showLoadingActivity() {
        addImageButton.isEnabled = false
        updatePersonButton.isEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        addImageButton.isEnabled = true
        updatePersonButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension DatabaseUpdatePersonViewController: UITextFieldDelegate {
    
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

extension DatabaseUpdatePersonViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let divider = UIDevice.current.orientation.isPortrait ? 2.0 : 3.0
        let side = collectionView.bounds.width / divider
        let size = CGSize(width: side, height: side)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 50)
    }
}

extension DatabaseUpdatePersonViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        pickedImages.isEmpty ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? personImages.count : pickedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdatePersonCell", for: indexPath) as? UpdatePersonCell else {
            fatalError("Unable to reuse cell")
        }
        
        if indexPath.section == 0 {
            let personImage = personImages[indexPath.row]
            cell.imageView.image = UIImage(named: "person_placeholder")
            let toRemove = personImagesToRemove.contains(where: { $0.itemId == personImage.itemId })
            cell.markToRemove = toRemove
            database.getPersonImage(personId: person.itemId, imageId: personImage.itemId) { [weak cell] response in
                if let data = response.data {
                    cell?.imageView.image = UIImage(data: data)
                }
            }
        } else if indexPath.section == 1 {
            cell.imageView.image = pickedImages[indexPath.row]
        }
        
        cell.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchPersonHeader.reuseID, for: indexPath) as? SearchPersonHeader else { return UICollectionReusableView() }
        header.headerLabel.text = indexPath.section == 0 ? "Person Images" : "New images"
        header.frame.size.height = 50
        return header
    }
}

extension DatabaseUpdatePersonViewController: ImagePickerDelegate {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType) {
        pickedImages.append(image)
        collectionView.reloadData()
    }
}

extension DatabaseUpdatePersonViewController: UpdateCellDelegate {
    
    func didReceiveRemoveAction(cell: UpdatePersonCell) {
        let section = collectionView.indexPath(for: cell)?.section
        if section == 0 {
            let personImage = personImages[cell.tag]
            personImagesToRemove.append(personImage)
        } else if section == 1 {
            let image = pickedImages[cell.tag]
            if let imageIndex = pickedImages.firstIndex(of: image) {
                pickedImages.remove(at: imageIndex)
                collectionView.reloadData()
            }
        }
    }
    
    func didReceiveCancelRemoveAction(cell: UpdatePersonCell) {
        let personImage = personImages[cell.tag]
        if let imageIndex = personImagesToRemove.firstIndex(of: personImage) {
            personImagesToRemove.remove(at: imageIndex)
        }
    }
}

private enum UpdatePersonError: LocalizedError {
    case personDataUpdateFailed(errors: [Error])
    case updateSkipped
    var errorDescription: String? {
        switch self {
        case .personDataUpdateFailed(errors: let errors):
            return errors.map({ $0.localizedDescription }).joined(separator: ",")
        case .updateSkipped:
            return "Nothing to update"
        }
    }
}
