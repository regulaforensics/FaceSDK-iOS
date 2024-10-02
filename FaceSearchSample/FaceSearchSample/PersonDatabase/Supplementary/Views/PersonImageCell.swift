//
//  PersonImageCell.swift
//  BasicSample
//
//  Created by Serge Rylko on 15.05.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation
import UIKit

class PersonImageCell: UICollectionViewCell {
    
    static let reuseID = String(describing: PersonImageCell.self)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
}
