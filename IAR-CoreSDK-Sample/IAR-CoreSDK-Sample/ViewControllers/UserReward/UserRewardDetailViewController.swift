//
//  UserRewardDetailViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-27.
//

import UIKit
import Foundation
import IAR_Core_SDK

class UserRewardDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var reasonTypeLabel: UILabel!
    @IBOutlet weak var actionButtonLabel: UILabel!
    @IBOutlet weak var actionTextLabel: UILabel!
    @IBOutlet weak var actionUrlLabel: UILabel!
    @IBOutlet weak var optionalTextLabel: UILabel!
    
    
    // MARK: - Properties
    
    var reward: Reward?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInfo()
    }

    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "Reward Details"
    }
    
    private func setupInfo() {
        // Check if a Reward was given when oppening the detail view
        guard let reward = self.reward else { return }
        
        self.nameLabel.text = reward.rewardName
        self.idLabel.text = reward.rewardId
        self.setupThumbnailImage(url: reward.file?.url)
        self.typeLabel.text = "Type: \(reward.rewardType?.rawValue ?? "")"
        self.actionButtonLabel.text = "Action Button: \(reward.actionButtonEnabled ? "ON" : "OFF")"
        self.actionTextLabel.text = "     Text: \(reward.actionButtonText ?? " --- ")"
        self.actionUrlLabel.text = "     URL: \(reward.actionButtonUrl ?? " --- ")"
        
        // Shows how the reward was earned. (it's origin: By Hunt or Marker).
        self.reasonTypeLabel.text = "Reason Type: \(reward.reasonType)"
        
        // Only Rewards of type PROMO CODE can have this small description.
        self.optionalTextLabel.text = "Optional Text: \(reward.generalPromoCode?.optionalText ?? " --- ")"
    }
    
    private func setupThumbnailImage(url: String?) {
        guard let url = url else { return }
        if let thumbnailImageURL = URL(string: url) {
            self.thumbnailImageView.setImageProgressive(with: thumbnailImageURL)
        }
    }
}
