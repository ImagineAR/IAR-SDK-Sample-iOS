//
//  UserManagementViewController.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2022-01-12.
//

import Foundation
import UIKit
import IAR_Core_SDK

internal class UserManagementViewController: UIViewController {

    // MARK: - Properties
    
    private let tableView = UITableView()
    private let model = UserManagementViewModel()
    private let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges).offset(16)
        }
        
        model.userController.loadCurrentUser(completion: self.completionHandler())
        
        title = "User Management"
    }
    
    // MARK: - Action Methods
    
    private func createUser() {
        let createDialog = UIAlertController.inputDialog(title: "Create New User",
                                                         message: "Enter the external UserID",
                                                         defaultValue: UUID().uuidString)
        
        createDialog.addAction(UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: { [weak createDialog, weak self] (_) in
            
            guard let textField = createDialog?.textFields![0],
                  let userId = textField.text,
                  let self = self,
                  !userId.isEmpty else {
                      return
                  }

            self.model.userController.createNewUser(with: userId, completion: self.completionHandler())
        }))
        
        self.present(createDialog, animated: true, completion: nil)
    }
    
    private func login() {
        let loginDialog = UIAlertController.inputDialog(title: "Login User",
                                                        message: "Enter the external UserID",
                                                        defaultValue: "")
        
        loginDialog.addAction(UIAlertAction(title: "OK",
                                            style: .default,
                                            handler: { [weak loginDialog, weak self] (_) in
            
            guard let textField = loginDialog?.textFields![0],
                  let userId = textField.text,
                  let self = self,
                  !userId.isEmpty else {
                      return
                  }
            
            self.model.userController.login(with: userId, completion: self.completionHandler())
        }))
        
        self.present(loginDialog, animated: true, completion: nil)
    }
    
    private func logout() {
        self.model.userController.logout(completion: self.completionHandler())
    }
    
    private func migrate() {
        let regenDialog = UIAlertController.inputDialog(title: "Regenerating UID",
                                                        message: "Current session and cache will be lost - would you like to migrate?",
                                                        defaultValue: UUID().uuidString)
        
        regenDialog.addAction(UIAlertAction(title: "Yes",
                                            style: .default,
                                            handler: { [weak self] (_) in
            
            self?.regenerateUser(alertController: regenDialog, willMigrate: true)
        }))
        regenDialog.addAction(UIAlertAction(title: "No",
                                            style: .destructive,
                                            handler: { [weak self] (_) in
            
            self?.regenerateUser(alertController: regenDialog, willMigrate: false)
        }))
        
        self.present(regenDialog, animated: true, completion: nil)
    }
    
    private func regenerateUser(alertController: UIAlertController, willMigrate: Bool) {
        guard let textField = alertController.textFields?[0],
              let userId = textField.text,
              !userId.isEmpty else {
                  return
              }
        
        model.userController.sampleRegenerate(shouldMigrate: willMigrate, newUserId: userId, stayGuest: !model.isLoggedIn) { [weak self] _, userId in
            
            self?.tableView.reloadData()
        }
    }
    
    private func completionHandler() -> ExternalUsersController.UserCompletion {
        return { [weak self] error , userId  in
            guard let self = self else { return }
            guard let error = error else {
                self.tableView.reloadData()
                return
            }
            
            let errorDialog = UIAlertController.defaultDialog(title: "User Operation Failed",
                                                              message: error.localizedDescription)
            self.present(errorDialog, animated: true, completion: nil)
            
            log("Failed with error: \(error.localizedDescription)")
        }
    }
}

extension UserManagementViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let dataItem = model.menuItems[indexPath.row]
        let identifier = "\(indexPath.row)" as NSString

        if dataItem.ID == .userID {
            return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
                guard let smallSymbolImage = UIImage(systemName: "doc.on.doc", withConfiguration: self.smallConfiguration) else {
                    return nil
                }

                let copyAction = UIAction(title: "Copy",
                                          image: smallSymbolImage.withTintColor(.tintColor)) { _ in
                    UIPasteboard.general.string = self.model.userID
                }
                return UIMenu(title: "", image: nil, children: [copyAction])
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = model.menuItems[indexPath.row]

        switch dataItem.ID {
            case .createUser:
                createUser()
            case .login:
                login()
            case .logout:
                logout()
            case .migrateUser:
                migrate()
            case .userIDLabel, .userID:
                // nothing to do
                log("Nothing to do")
        }
    }
}


extension UserManagementViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basicCell"
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        
        let dataItem = model.menuItems[indexPath.row]
        
        if (dataItem.Icon != "") {
            let smallSymbolImage = UIImage(systemName: dataItem.Icon, withConfiguration: smallConfiguration)
            cell.imageView?.image = smallSymbolImage
        } else {
            let size: Int = 24
            let bounds = CGRect(x: 0, y: 0, width: size, height: size)
            cell.imageView?.image = UIGraphicsImageRenderer(size: bounds.size).image { _ in
                UIColor.clear.setFill()
                UIRectFill(bounds)
            }
        }
        
        if (dataItem.ID == .userID) {
            cell.textLabel?.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        }
        
        cell.textLabel?.text = dataItem.Title
        
        return cell
    }
}
