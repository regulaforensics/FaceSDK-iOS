//
//  Person+Metadata.swift
//  BasicSample
//
//  Created by Serge Rylko on 27.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation
import FaceSDK

extension PersonDatabase.Person {
    
    var surname: String? {
        get {
            metadata["surname"] as? String
        }
        set {
            metadata["surname"] = newValue
        }
    }
}
