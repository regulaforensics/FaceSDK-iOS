//
//  DBButton.swift
//  FaceSearchSample
//
//  Created by Serge Rylko on 18.07.24.
//

import UIKit

class DBButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.backgroundColor = UIColor(named: "windsor")
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.setTitleColor(.white, for: .normal)
    }
}
