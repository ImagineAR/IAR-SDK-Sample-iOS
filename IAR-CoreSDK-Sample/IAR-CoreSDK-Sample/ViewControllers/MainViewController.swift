//
//  MainViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-12.
//

import UIKit
import IAR_Core_SDK

class MainViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Controllers
    
    private let menuController = MenuController()
    
    // MARK: - Properties

    var tableHeaderView: UIView?
    let sectionHeight: CGFloat = 166
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLicense()
    }

    
    // MARK: - Setup
    
    private func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        if let headerView = Bundle.main.loadNibNamed("mainViewHeader", owner: self, options: nil)?.first as? UIView {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(headerView)
            self.tableHeaderView = containerView
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = sectionHeight
        }
    }
    
    private func setupLicense() {
        // Public Key. Replace with your license key.
        let licenseKey: String = "pk_org_d5f1fca52da847c9a1a064619b91c74e"
        
        // Calling 'validateLicense' will try to authenticate.
        // A success doesn't mean the key is activated or authorized.
        IARLicenseManager.shared().validateLicense(licenseKey, serverType: .US) { [weak self] error in
            if let error = error {
                FileLogger.shared.log(content: "Authentication failed. Error: \(error.localizedDescription)")
            } else {
                
                // To call the SDK methods, we'll need an user ID.
                self?.setupExternalUser()
            }
        }
        
        // We can consult the key anytime:
        let isLicenseValid: Bool = IARLicenseManager.shared().iarLicenseIsValid
        let licenseString: String = IARLicenseManager.shared().iarLicense()
        FileLogger.shared.log(content: "License: '\(licenseString)'. Is valid? \(isLicenseValid)")
    }
    
    private func setupExternalUser() {
        // We'll use a random one
        let userID = UUID().uuidString
        
        // Creates a new user ID
        IARNetworkManager.shared().createExternalUserId(userID) { createdUserId, error in
            if let error = error {
                FileLogger.shared.log(content: "Failed to create UserID. Error: \(error.localizedDescription)")
            } else if let userId = createdUserId {
                // If it was able to create, set it as the current user ID
                IARNetworkManager.shared().setExternalUserId(userId, clearCache: true)
                FileLogger.shared.log(content: "New User ID: \(userId)")
            }
        }
    }
}


// MARK: - Extensions

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = menuController.menuItems[indexPath.row]
        
        switch dataItem.ID {
            case .userManagement:
                let view = UserManagementViewController()
                self.navigationController?.pushViewController(view, animated: true)
            case .userRewards:
                self.performSegue(withIdentifier: "segueUserRewards", sender: nil)
            case .locationMarkers:
            self.performSegue(withIdentifier: "segueLocationMarkers", sender: nil)
            case .onDemandMarkers:
                self.performSegue(withIdentifier: "segueOnDemandMarkers", sender: nil)
            case .arHunts:
                self.performSegue(withIdentifier: "segueARHunts", sender: nil)
            case .debugTools:
                // You can add custom commands if you want to on the debugTool
                // In this example, we are adding a custom location
                // For more details, see "DebugLocationCommand"
                let view = IARDebugViewController(customCommands: [DebugLocationCommand()])
                self.navigationController?.pushViewController(view, animated: true)
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuController.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basicCell"
        let cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        
        let dataItem = menuController.menuItems[indexPath.row]
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let smallSymbolImage = UIImage(systemName: dataItem.Icon, withConfiguration: smallConfiguration)
        
        cell.imageView?.image = smallSymbolImage
        cell.textLabel?.text = dataItem.Title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        section == 0 ? self.tableHeaderView : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? self.sectionHeight : 0
    }
}

// A small extension to make the navigation bar hide when keyboard appears
extension IARDebugViewController {
    
    override public func viewDidAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
        super.viewDidAppear(animated)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        super.viewDidDisappear(animated)
    }
}
