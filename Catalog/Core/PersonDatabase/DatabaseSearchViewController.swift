//
//  DatabaseSearchViewController.swift
//  Catalog
//
//  Created by Serge Rylko on 20.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class DatabaseSearchViewController: UIViewController {

    @IBOutlet private weak var browseButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pickedImageView: UIImageView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    private var selectedImage: UIImage?
    private var results: [PersonDatabase.SearchPerson] = []
    private lazy var imagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)
    
    var groupIds: [String]?
    var group: PersonDatabase.PersonGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let group = group {
            title = "Search Person in '\(group.name)'"
        } else {
            title = "Search Person"
        }
        let button = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(didTapClearButton))
        navigationItem.setRightBarButton(button, animated: false)
        collectionView.register(SearchPersonHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchPersonHeader.reuseID)
        collectionView.register(SearchPersonImageCell.self, forCellWithReuseIdentifier: SearchPersonImageCell.reuseID)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Database
    private func searchPerson(imageData: Data, completion: @escaping (Result<[PersonDatabase.SearchPerson], Error>) -> Void) {
        let upload = PersonDatabase.ImageUpload(imageData: imageData)
        let searchRequest = PersonDatabase.SearchPersonRequest(imageUpload: upload)
        searchRequest.detectAll = true
        if let group = group {
            searchRequest.groupIdsForSearch = [group.itemId]
        }  else if let groupIds = groupIds {
            searchRequest.groupIdsForSearch = groupIds
        }
        FaceSDK.service.personDatabase.searchPerson(searchRequest: searchRequest) { response in
            if let results = response.results {
                completion(.success(results))
            } else if let error = response.error {
                completion(.failure(error))
            }
        }
    }
    
    private func handleFailure(error: Error) {
        let alert = UIAlertController(title: "Failure", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func handleSuccess(results: [PersonDatabase.SearchPerson]) {
        self.results = results
        showFacemarks()
        collectionView.reloadData()
    }
    
    private func showFacemarks() {
        let detections = results.map({ $0.detection })
        guard !detections.isEmpty else { return }
        guard let image = pickedImageView.image else { return }
        
        // scale lines and points according target view size
        let scale = image.size.width / pickedImageView.bounds.width
        let lineWidth = 2.0 * scale
        let pointSize = 3.0 * scale

        let imageWithDetectionMarks = detections.reduce(image) { resultImage, detection in
            return ImageHelper.drawFaceDetection(onImage: resultImage,
                                                 searchDetection: detection,
                                                 color: .green,
                                                 lineWidth: lineWidth,
                                                 pointSize: pointSize) ?? UIImage()
        }
        pickedImageView.image = imageWithDetectionMarks
    }

    //MARK: - Actions
    @IBAction private func didTapBrowseButton(_ sender: Any) {
        imagePicker.presentDefaultActions(from: view)
    }
    
    @IBAction private func didTapSearchButton(_ sender: Any) {
        guard let image = selectedImage, let imageData = image.pngData() else { return }
        
        showLoadingActivity()
        searchPerson(imageData: imageData) { [weak self] result in
            guard let self = self else { return }
            self.hideLoadingActivity()
            switch result {
            case .success(let results):
                self.handleSuccess(results: results)
            case .failure(let error):
                self.handleFailure(error: error)
            }
        }
    }
    
    @objc private func didTapClearButton(_ sender: Any) {
        pickedImageView.image = UIImage(named: "person_placeholder")
        selectedImage = nil
        results = []
        collectionView.reloadData()
    }
    
    //MARK: - Loaging states
    private func showLoadingActivity() {
        browseButton.isEnabled = false
        searchButton.isEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        browseButton.isEnabled = true
        searchButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension DatabaseSearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        results[section].images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPersonImageCell.reuseID, for: indexPath) as? SearchPersonImageCell else {
            fatalError("Unable to reuse cell")
        }
        let resultImage = results[indexPath.section].images[indexPath.row]
        cell.imageView.image = UIImage(named: "person_placeholder")
        cell.imageView.load(url: resultImage.url)
        let roundedSimilarity = (resultImage.similarity.floatValue * 100).rounded() / 100
        let roundedDistance = (resultImage.distance.floatValue * 100).rounded() / 100
        cell.similarityLabel.text = "Similarity: \(roundedSimilarity)"
        cell.distanceLabel.text = "Distance: \(roundedDistance)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchPersonHeader.reuseID, for: indexPath) as? SearchPersonHeader else { return UICollectionReusableView() }
        let result = results[indexPath.section]
        let resultText = "\(indexPath.section + 1). \(result.name) \(result.surname ?? "")"
        header.headerLabel.text = resultText
        header.frame.size.height = 50
        return header
    }
}

extension DatabaseSearchViewController: UICollectionViewDelegate {}

extension DatabaseSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = collectionView.bounds.width / 2.0
        let size = CGSize(width: side, height: side)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 50.0)
    }
}

extension DatabaseSearchViewController: ImagePickerDelegate {
   
    func didPickImage(delegate: ImagePicker, image: UIImage) {
        selectedImage = image
        pickedImageView.image = image
    }
}
