//
//  UIImageView+Load.swift
//  Catalog
//
//  Created by Serge Rylko on 15.05.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func load(url: URL) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }.resume()
    }
}

