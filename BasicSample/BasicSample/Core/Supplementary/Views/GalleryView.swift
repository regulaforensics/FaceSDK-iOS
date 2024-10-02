//
//  GalleryView.swift
//  BasicSample
//
//  Created by Serge Rylko on 6.09.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import UIKit

protocol GalleryViewDelegate: AnyObject {
    func didSelectImage(gallery: GalleryView, image: UIImage, selectedImageIndex: Int, detailImageSetter: ((UIImage) -> Void)?)
}

class GalleryView: UIView {
    
    private class DetectImageModel {
        
        let image: UIImage
        var detailImage: UIImage? = nil
        
        init(image: UIImage, detectedImage: UIImage? = nil) {
            self.image = image
            self.detailImage = detectedImage
        }
    }
    
    private let previewImageView = UIImageView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    weak var delegate: GalleryViewDelegate? {
        didSet { notifySelection() }
    }
    
    var images: [UIImage] = [] {
        didSet { buildModels(); updateContent() }
    }
    
    private var models: [DetectImageModel] = []
    var selectedIndex: Int = 0 {
        didSet { updateSelection(); notifySelection() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        buildModels()
        updateContent()
    }
    
    init(images: [UIImage]) {
        self.images = images
        super.init(frame: .zero)
        setup()
        buildModels()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        previewImageView.backgroundColor = .white
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = true
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DetectImagePickerCell.self, forCellWithReuseIdentifier: DetectImagePickerCell.reuseID)
        addSubview(previewImageView)
        addSubview(collectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [previewImageView, collectionView].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: topAnchor),
            previewImageView.leftAnchor.constraint(equalTo: leftAnchor),
            previewImageView.rightAnchor.constraint(equalTo: rightAnchor),
            previewImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.75),
            
            collectionView.topAnchor.constraint(equalTo: previewImageView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func buildModels() {
        models = images.map { DetectImageModel(image: $0) }
    }
    
    private func updateContent() {
        collectionView.reloadData()
        updateSelection()
    }
    
    private func updateSelection() {
        guard !models.isEmpty else { return }
        let model = models[selectedIndex]
        previewImageView.image = model.detailImage ?? model.image
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    private func notifySelection() {
        let model = models[selectedIndex]
        let image = model.image
        
        delegate?.didSelectImage(gallery: self, image: image, selectedImageIndex: selectedIndex, detailImageSetter: { [weak self] image in
            model.detailImage = image
            self?.updateContent()
        })
    }
}


extension GalleryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetectImagePickerCell.reuseID, for: indexPath) as? DetectImagePickerCell
        else {
            fatalError("dequeue cell failure")
        }
        cell.imageView.image = models[indexPath.row].image
        return cell
    }
}

extension GalleryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: bounds.width / 4, height: collectionView.bounds.height)
    }
}

extension GalleryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
}

class DetectImagePickerCell: UICollectionViewCell {
    
    static let reuseID = String(describing: DetectImagePickerCell.self)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            highlightSelection()
        }
    }
    
    private func setup() {
        backgroundColor = .white
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    private func highlightSelection() {
        layer.borderColor = UIColor.windsor.cgColor
        layer.borderWidth = isSelected ? 5.0 : 0.0
        layer.cornerRadius = 3.0
    }
}
