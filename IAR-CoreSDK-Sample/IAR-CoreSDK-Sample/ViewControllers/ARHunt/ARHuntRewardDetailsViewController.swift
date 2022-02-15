//
//  ARHuntRewardDetailsViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-02-04.
//

import UIKit
import IAR_Core_SDK

class ARHuntRewardDetailsViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    // MARK: - Properties
    
    var huntReward: HuntReward?
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInfo()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "ARHunt Reward Details"
    }
    
    private func setupInfo() {
        // Check if a Hunt Reward was given when oppening the detail view
        guard let huntReward = self.huntReward else { return }
        guard let reward = huntReward.reward else { return }
        
        self.nameLabel.text = reward.rewardName
        self.idLabel.text = huntReward.huntRewardId
        self.setupThumbnailImage(url: reward.file?.url)
        self.detailsTextView.text = huntReward.printInspection()
    }
    
    private func setupThumbnailImage(url: String?) {
        guard let url = url else { return }
        if let thumbnailImageURL = URL(string: url) {
            self.thumbnailImageView.setImageProgressive(with: thumbnailImageURL)
        }
    }
}

