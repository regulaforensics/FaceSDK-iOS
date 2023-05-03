//
//  PersonDatabaseItem.swift
//  Catalog
//
//  Created by Serge Rylko on 2.05.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import Foundation

class PersonDatabaseItem: CatalogItem {
  
  override init() {
    super.init()
    self.title = "Search Person"
    self.itemDescription = "Search Person in database by image"
    self.category = .basic
  }

  override func onItemSelected(from viewController: UIViewController) {
      let vc = DatabaseGroupsViewController()
      viewController.show(vc, sender: nil)
  }
}
