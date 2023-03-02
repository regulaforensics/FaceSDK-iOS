//
//  CatalogViewController.swift
//  Catalog
//
//  Created by Pavel Kondrashkov on 5/18/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import UIKit
import FaceSDK

final class CatalogViewController: UIViewController {
    private let tableDataProvider = CatalogTableDataProvider()

    lazy var tableView: UITableView = {
        var style: UITableView.Style = .grouped
        if #available(iOS 13, *) {
            style = .insetGrouped
        }

        let view = UITableView(frame: .zero, style: style)
        view.dataSource = self
        view.delegate = self
        view.estimatedSectionHeaderHeight = 30
        view.cellLayoutMarginsFollowReadableWidth = true
        view.register(CatalogTableViewCell.self, forCellReuseIdentifier: String(describing: CatalogTableViewCell.self))
        return view
    }()

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FaceSDK.service.initialize { success, error in
            if error == nil {
                print("FaceSDK initialized.")
            } else {
                print(error?.localizedDescription ?? "")
            }
        }

        title = "FaceSDK Catalog"
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }
}

extension CatalogViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableDataProvider.content.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableDataProvider.content[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CatalogTableViewCell.self), for: indexPath) as! CatalogTableViewCell

        let row = tableDataProvider.content[indexPath.section].rows[indexPath.row]
        cell.setup(with: row)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableDataProvider.content[section].title
    }
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        guard let item = tableDataProvider.catalogItemForIndexPath(indexPath) else {
            print("Failed to fetch catalog item.")
            return
        }

        if let itemViewController = item.build() {
            present(itemViewController, animated: true)
        } else {
            item.onItemSelected(from: self)
        }
    }
}

final class CatalogTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(with row: CatalogRow) {
        textLabel?.font = .preferredFont(forTextStyle: .subheadline)
        textLabel?.numberOfLines = 0
        textLabel?.text = row.title

        detailTextLabel?.textColor = UIColor.darkGray
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.text = row.description
    }
}
