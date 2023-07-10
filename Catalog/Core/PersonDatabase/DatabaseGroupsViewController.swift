//
//  DatabaseGroupsViewController.swift
//  Catalog
//
//  Created by Serge Rylko on 20.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class DatabaseGroupsViewController: UIViewController {

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var groupsTableView: UITableView!
    @IBOutlet private weak var searchButton: UIButton!
    
    private let database: PersonDatabase = FaceSDK.service.personDatabase
    private var groups: [PersonDatabase.PersonGroup] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Groups"
        
        let createBarButton = UIBarButtonItem(title: "Create Group", style: .plain, target: self, action: #selector(didPressCreateButton))
        navigationItem.setRightBarButton(createBarButton, animated: false)
        
        loadGroups()
    }
    
    //MARK: - Database
    private func loadGroups() {
        showLoadingActivity()
        database.getGroups { [weak self] response in
            self?.hideLoadingActivity()
            if let groups = response.items {
                self?.groups = groups
                self?.groupsTableView.reloadData()
            } else if let error = response.error {
                self?.showError(error: error)
            }
        }
    }
    
    private func showGroup(group: PersonDatabase.PersonGroup) {
        let vc = DatabasePersonsViewController(group: group)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deleteGroup(group: PersonDatabase.PersonGroup) {
        showLoadingActivity()
        database.deleteGroup(groupId: group.itemId) { [weak self] response in
            self?.hideLoadingActivity()
            if let error = response.error {
                self?.showError(error: error)
            } else {
                self?.loadGroups()
            }
        }
    }
    
    private func updateGroup(group: PersonDatabase.PersonGroup) {
        showLoadingActivity()
        database.updateGroup(group: group){ [weak self] response in
            self?.hideLoadingActivity()
            if let error = response.error {
                self?.showError(error: error)
            } else {
                self?.loadGroups()
            }
        }
    }
    
    //MARK: - Dialogs
    private func createGroup(name: String) {
        showLoadingActivity()
        database.createGroup(name: name, metadata: nil) { [weak self] response in
            self?.hideLoadingActivity()
            if let error = response.error {
                self?.showError(error: error)
            } else {
                self?.loadGroups()
            }
        }
    }
    
    private func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(actionOK)
        present(alert, animated: true)
    }
    
    private func showCreateGroupDialog() {
        let alert = UIAlertController(title: "Create PersonGroup", message: "Enter a name for a new PersonGroup", preferredStyle: .alert)
        alert.addTextField()
        let actionCreate = UIAlertAction(title: "Create", style: .default) { [weak alert, weak self] _ in
            let name = alert?.textFields?.first?.text
            if let name = name {
                self?.createGroup(name: name)
            }
            alert?.dismiss(animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCreate)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    private func showDeleteGroupDialog(for group: PersonDatabase.PersonGroup) {
        let alert = UIAlertController(title: "Delete PersonGroup", message: "Delete PersonGroup '\(group.name)' from database", preferredStyle: .alert)
        
        let actionCreate = UIAlertAction(title: "Delete", style: .destructive) { [weak alert, weak self] _ in
            self?.deleteGroup(group: group)
            alert?.dismiss(animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCreate)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    private func showUpdateGroupDialog(for group: PersonDatabase.PersonGroup) {
        let alert = UIAlertController(title: "Update PersonGroup", message: "Enter new name for PersonGroup '\(group.name)'", preferredStyle: .alert)
        alert.addTextField()
        let actionCreate = UIAlertAction(title: "Update", style: .default) { [weak alert, weak self] _ in
            let name = alert?.textFields?.first?.text
            if let name = name {
                group.name = name
                self?.updateGroup(group: group)
            }
            alert?.dismiss(animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCreate)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }

    //MARK: - Actions
    @IBAction private func didPressSearchButton(_ sender: Any) {
        let groupIds = self.groups.map({ $0.itemId })
        let vc = DatabaseSearchViewController()
        vc.groupIds = groupIds
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func didPressCreateButton(_ sender: Any) {
        showCreateGroupDialog()
    }
    
    //MARK: - Loading states
    private func showLoadingActivity() {
        searchButton.isEnabled = false
        groupsTableView.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        searchButton.isEnabled = true
        groupsTableView.isUserInteractionEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension DatabaseGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonGroupReuseID") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "PersonGroupReuseID")
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = group.itemId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
}

extension DatabaseGroupsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        showGroup(group: group)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let group = groups[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete group") { [weak self] action, view, completion in
            self?.showDeleteGroupDialog(for: group)
            completion(true)
        }
        let updateAction = UIContextualAction(style: .normal, title: "Update Group") { [weak self] action, view, completion in
            self?.showUpdateGroupDialog(for: group)
            completion(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
