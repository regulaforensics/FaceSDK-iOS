//
//  SearchPersonHeader.swift
//  Catalog
//
//  Created by Serge Rylko on 15.05.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation
import UIKit

class SearchPersonHeader: UICollectionReusableView {
    
    static let reuseID = String(describing: SearchPersonHeader.self)
    
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(headerLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerLabel.frame = bounds
        headerLabel.textAlignment = .center
    }
}

