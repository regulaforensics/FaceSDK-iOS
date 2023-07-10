//
//  SearchPersonImageCell.swift
//  Catalog
//
//  Created by Serge Rylko on 15.05.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation
import UIKit


class SearchPersonImageCell: UICollectionViewCell {
    
    static let reuseID = String(describing: SearchPersonImageCell.self)
    
    let imageView = UIImageView()
    let similarityLabel = UILabel()
    let distanceLabel = UILabel()
    private let stackView = UIStackView()
    private let stackContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        stackContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .trailing
        stackView.addArrangedSubview(similarityLabel)
        stackView.addArrangedSubview(distanceLabel)
        
        similarityLabel.font = .systemFont(ofSize: 12)
        similarityLabel.textColor = .white
        similarityLabel.adjustsFontSizeToFitWidth = true
        distanceLabel.font = .systemFont(ofSize: 12)
        distanceLabel.textColor = .white
        distanceLabel.adjustsFontSizeToFitWidth = true
        stackContainer.addSubview(stackView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(stackContainer)
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackContainer.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stackContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackContainer.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
            stackContainer.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalTo: stackContainer.topAnchor),
            stackView.leftAnchor.constraint(equalTo: stackContainer.leftAnchor, constant: 10),
            stackView.rightAnchor.constraint(equalTo: stackContainer.rightAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: stackContainer.bottomAnchor),
        ])
    }
}
