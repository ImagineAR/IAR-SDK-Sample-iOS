//
//  ViewController.swift
//  IAR-TargetSDK-Sample
//
//  Created by Rogerio on 2021-12-11.
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
        
        setupViews()
        setupLicense()
    }
    
    
    // MARK: - Setup
    
    private func setupViews() {
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
                log("Authentication failed. Error: \(error.localizedDescription)")
            } else {
                
                // To call the SDK methods, we'll need an user ID.
                self?.setupExternalUser()
            }
        }
        
        // We can consult the key anytime:
        let isLicenseValid: Bool = IARLicenseManager.shared().iarLicenseIsValid
        let licenseString: String = IARLicenseManager.shared().iarLicense()
        log("License: '\(licenseString)'. Is valid? \(isLicenseValid)")
    }
    
    private func setupExternalUser() {
        // We'll use a random one
        let userID = UUID().uuidString
        
        // Creates a new user ID
        IARNetworkManager.shared().createExternalUserId(userID) { createdUserId, error in
            if let error = error {
                log("Failed to create UserID. Error: \(error.localizedDescription)")
            } else if let userId = createdUserId {
                // If it was able to create, set it as the current user ID
                IARNetworkManager.shared().setExternalUserId(userId, clearCache: true)
                log("New User ID: \(userId)")
            }
        }
    }
}

// MARK: - Extensions

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = menuController.menuItems[indexPath.row]
        
        switch dataItem.ID {
            case .scanARTarget: // Opens Scan AR ViewController
                self.performSegue(withIdentifier: "segueScanARTarget", sender: self)
            case .debugTools:
                let view = IARDebugViewController(customCommands: [])
                present(view, animated: true) // We recommend to present it as a modal.
            case .userManagement:
                let view = UserManagementViewController()
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
