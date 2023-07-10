//
//  DatabasePersonsViewController.swift
//  Catalog
//
//  Created by Serge Rylko on 21.06.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class DatabasePersonsViewController: UIViewController {
    
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var personsTableView: UITableView!
    
    private let database: PersonDatabase = FaceSDK.service.personDatabase
    
    private var persons: [PersonDatabase.Person] = []
    private let group: PersonDatabase.PersonGroup
    
    init(group: PersonDatabase.PersonGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = group.name
        
        let createBarButton = UIBarButtonItem(title: "Create Person", style: .plain, target: self, action: #selector(didPressCreateButton))
        navigationItem.setRightBarButton(createBarButton, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPersons()
    }
    
    //MARK: - Database
    private func loadPersons() {
        showLoadingActivity()
        database.getGroupPersons(groupId: group.itemId) { [weak self] response in
            self?.hideLoadingActivity()
            if let persons = response.items {
                self?.persons = persons
                self?.personsTableView.reloadData()
            } else if let error = response.error {
                self?.showError(error: error)
            }
        }
    }
    
    private func deletePerson(person: PersonDatabase.Person) {
        showLoadingActivity()
        database.deletePerson(personId: person.itemId) { [weak self] response in
            self?.hideLoadingActivity()
            if let error = response.error {
                self?.showError(error: error)
            } else {
                self?.loadPersons()
            }
        }
    }
    
    private func removePersonFromGroup(person: PersonDatabase.Person) {
        showLoadingActivity()
        let editRequest =  PersonDatabase.EditGroupPersonsRequest(personIdsToAdd: nil, personIdsToRemove: [person.itemId])
        database.editGroupPersons(groupId: group.itemId, request: editRequest) { [weak self] response in
            self?.hideLoadingActivity()
            if let error = response.error {
                self?.showError(error: error)
            } else {
                self?.loadPersons()
            }
        }
    }
    
    //MARK: - Navigation
    private func showUpdatePerson(person: PersonDatabase.Person) {
        let vc = DatabaseUpdatePersonViewController(person: person)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showCreatePerson() {
        let vc = DatabaseCreatePersonViewController(group: group)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Dialogs
    private func showError(error: Error) {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(actionOK)
        present(alert, animated: true)
    }
    
    private func showDeletePersonDialog(for person: PersonDatabase.Person) {
        let alert = UIAlertController(title: "Delete Person",
                                      message: "Delete Person '\(group.name)' from database",
                                      preferredStyle: .alert)
        
        let actionCreate = UIAlertAction(title: "Delete", style: .destructive) { [weak alert, weak self] _ in
            self?.deletePerson(person: person)
            alert?.dismiss(animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCreate)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    private func showRemovePersonFromGroupDialog(for person: PersonDatabase.Person) {
        let alert = UIAlertController(title: "Remove Person from group",
                                      message: "Remove Person '\(person.name)' from group '\(group.name)'",
                                      preferredStyle: .alert)
        
        let actionCreate = UIAlertAction(title: "Remove", style: .destructive) { [weak alert, weak self] _ in
            self?.removePersonFromGroup(person: person)
            alert?.dismiss(animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCreate)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    //MARK: - Actions
    @IBAction private func didPressSearchButton(_ sender: Any) {
        let vc = DatabaseSearchViewController()
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func didPressCreateButton(_ sender: Any) {
        showCreatePerson()
    }
    //MARK: - Loading states
    private func showLoadingActivity() {
        searchButton.isEnabled = false
        personsTableView.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        searchButton.isEnabled = true
        personsTableView.isUserInteractionEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension DatabasePersonsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonGroupReuseID") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "PersonGroupReuseID")
        let person = persons[indexPath.row]
        let title = "\(person.name) \(person.surname as? String ?? "")"
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = person.itemId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

extension DatabasePersonsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = persons[indexPath.row]
        showUpdatePerson(person: person)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let person = persons[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete person") { [weak self] action, view, completion in
            self?.showDeletePersonDialog(for: person)
            completion(true)
        }
        let removeFromGroupAction = UIContextualAction(style: .normal, title: "Remove from Group") { [weak self] action, view, completion in
            self?.showRemovePersonFromGroupDialog(for: person)
            completion(true)
        }
        removeFromGroupAction.backgroundColor = .orange
        let updateAction = UIContextualAction(style: .normal, title: "Update person") { [weak self] action, view, completion in
            self?.showUpdatePerson(person: person)
            completion(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction, removeFromGroupAction, updateAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
