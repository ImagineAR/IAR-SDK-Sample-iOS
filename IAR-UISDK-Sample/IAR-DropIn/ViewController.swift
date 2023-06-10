//
//  ViewController.swift
//  IAR-DropIn
//
//  Created by Andrew Burger on 04/29/2023.
//  Copyright (c) 2023 Andrew Burger. All rights reserved.
//

import UIKit
import IAR_UI_SDK
import IAR_Core_SDK

class ViewController: UIViewController {
    private let stackView = UIStackView()
    private var tableView = UITableView()
    private let experiences: [ARView.ARExperiences] = [.homeScreen, .target, .surface, .onDemand, .location, .rewards, .hunts]
    private var selectedItemsCounter: Int = -1
    private var selectedExperiences: [ARView.ARExperiences] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "AR Demo"
        
        ARView.branding = ARView.Branding(
            primaryColor: UIColor(red: 0x24/0xFF, green: 0x13/0xFF, blue: 0x5F/0xFF, alpha: 1.0),
            secondaryColor: UIColor(red: 0x9A/0xFF, green: 0x76/0xFF, blue: 0x11/0xFF, alpha: 1.0),
            brandIcon: UIImage(named: "AR_Brand_Example")
        )
        NotificationCenter.default.addObserver(self, selector: #selector(showARError(_:)), name: ARView.errorNotificationName, object: nil)

        
        let licenseKey: String = "pk_org_d5f1fca52da847c9a1a064619b91c74e"
        
        // Calling 'validateLicense' will try to authenticate.
        // A success doesn't mean the key is activated or authorized.
        IARLicenseManager.shared().validateLicense(licenseKey, serverType: .US) { [weak self] error in
            if let error = error {
                print("Authentication failed. Error: \(error.localizedDescription)")
            } else {
                print("License success.")
                // To call the SDK methods, we'll need an user ID.
//                 self?.useOldUser()
                self?.useNewUser()
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(changeSelectedItems))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        changeSelectedItems()
        
        navigationController?.navigationBar.backgroundColor = ARView.branding.primaryColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    private func useNewUser() {
        let userID = UUID().uuidString
        // Creates a new user ID
        IARNetworkManager.shared().createExternalUserId(userID) { createdUserId, error in
            if let error = error {
                print("Failed to create UserID. Error: \(error.localizedDescription)")
            } else if let userId = createdUserId {
                // If it was able to create, set it as the current user ID
                IARNetworkManager.shared().setExternalUserId(userId, clearCache: false)
                print("New User ID: \(userId)")
            }
        }
    }
    
    private func useOldUser() {
        IARNetworkManager.shared().setExternalUserId("CDAC7A4F-91E0-4CFE-9C19-FE7819DEF80F", clearCache: false)
    }
    
    @objc private func changeSelectedItems() {
        selectedItemsCounter += 1
        
        let selectedItemsLists: [[ARView.ARExperiences]] = [
            experiences,
            [.homeScreen,.target, .surface, .location, .rewards, .hunts],
            [.target, .rewards, .hunts],
            [.surface, .location, .rewards],
            [.homeScreen, .target, .surface, .onDemand, .location]
        ]
        
        if selectedItemsCounter >= selectedItemsLists.count {
            selectedItemsCounter = 0
        }
        
        selectedExperiences = selectedItemsLists[selectedItemsCounter]
        tableView.reloadData()
    }
    
    @objc func showARError(_ notification: NSNotification) {
        if let viewController = notification.userInfo?[ARView.errorNotificationViewController] as? UIViewController,
           let errorMessage = notification.userInfo?[ARView.errorNotificationMessage] as? String {
            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: - Extensions

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        ARView.availableExperiences = selectedExperiences
        
        let errorMessage = ARView.showExperience(experiences[indexPath.row], on: navigationController)
        
        if let errorMessage = errorMessage {
            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experiences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Basic Cell")
        cell.textLabel?.text = experiences[indexPath.row].name
        cell.accessoryType = selectedExperiences.contains(experiences[indexPath.row]) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
