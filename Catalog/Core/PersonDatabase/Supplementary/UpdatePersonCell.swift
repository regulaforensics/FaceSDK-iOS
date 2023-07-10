//
//  UpdatePersonCell.swift
//  Catalog
//
//  Created by Serge Rylko on 27.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit

protocol UpdateCellDelegate: AnyObject {
    func didReceiveRemoveAction(cell: UpdatePersonCell)
    func didReceiveCancelRemoveAction(cell: UpdatePersonCell)
}

class UpdatePersonCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var removeButton: UIButton!
    weak var delegate: UpdateCellDelegate?
    var markToRemove = false {
        didSet {
            updateRemoveState()
        }
    }
    
    @IBAction func didPressRemoveButton(_ sender: Any) {
        if !markToRemove {
            delegate?.didReceiveRemoveAction(cell: self)
        } else {
            delegate?.didReceiveCancelRemoveAction(cell: self)
        }
        markToRemove.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        markToRemove = false
//        imageView.alpha = 1.0
        imageView.image = .init(named: "person_placeholder")
    }
    
    private func updateRemoveState() {
        imageView.alpha = markToRemove ? 0.5 : 1.0
        let removeButtonTitle = markToRemove ? "Cancel remove" : "Remove image"
        removeButton.setTitle(removeButtonTitle, for: .normal)
    }
    
}
