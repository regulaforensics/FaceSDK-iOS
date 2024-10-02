//
//  CarouselView.swift
//  BasicSample
//
//  Created by Serge Rylko on 6.09.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import UIKit

protocol CarouselViewDelegate: AnyObject {
    func didSelectImage(delegate: CarouselView, atIndex index: Int)
}

class CarouselView: UIView {
    
    var selectedIndex: Int? = nil {
        didSet { updateLabel() }
    }
    var images: [UIImage] {
        didSet { updateContent() }
    }
    weak var delegate: CarouselViewDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: bounds,
                                              collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.indicatorStyle = .white
        collectionView.flashScrollIndicators()
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseID)
        return collectionView
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        label.textColor = .white
        return label
    }()
    
    init(images: [UIImage]) {
        self.images = images
        super.init(frame: .zero)
        setup()
        updateContent()
    }
    
    override init(frame: CGRect) {
        self.images = []
        super.init(frame: frame)
        setup()
        updateContent()
    }
    
    private func setup() {
        addSubview(collectionView)
        addSubview(indexLabel)
        setupConstraints()
    }
    
    private func updateContent() {
        collectionView.reloadData()
        updateLabel()
    }

    private func updateLabel() {
        indexLabel.isHidden = images.count <= 1
        indexLabel.text = " \((self.selectedIndex ?? 0) + 1) / \(images.count) "
    }

    func setupConstraints() {
        [collectionView, indexLabel].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            indexLabel.topAnchor.constraint(equalTo: topAnchor),
            indexLabel.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CarouselView: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.reuseID, for: indexPath) as? CarouselCell
        else {
            fatalError("dequeueReusableCell failure")
        }
        
        let image = images[indexPath.row]
        cell.imageView.image = image
        
        return cell
    }
}

extension CarouselView: UICollectionViewDelegate {}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}

extension CarouselView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let center = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                             y: collectionView.center.y + collectionView.contentOffset.y)
        if let indexPath = collectionView.indexPathForItem(at: center) {
            selectedIndex = indexPath.row
            delegate?.didSelectImage(delegate: self, atIndex: indexPath.row)
        }
    }
}

class CarouselCell: UICollectionViewCell {
    
    static let reuseID = String(describing: CarouselCell.self)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}
