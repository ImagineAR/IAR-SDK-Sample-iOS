//
//  UserRewardsViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-27.
//

import UIKit
import Foundation
import IAR_Core_SDK
import Accelerate
import SwiftUI

class UserRewardsViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties

    var rewardList: [Reward] = []
    var selectedReward: Reward?
        
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getUserRewards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check to see if there is a selected reward
        guard let reward = self.selectedReward else { return }
        
        // Show the reward details
        if segue.identifier == "segueUserRewardDetails"{
            if let details = segue.destination as? UserRewardDetailViewController {
                details.reward = reward
            }
        }
    }

        
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "User Rewards"
        
        // TableView setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCellIdentifier")
    }
    
    
    // MARK: - methods - UserRewards
    
    func getUserRewards() {
        IARNetworkManager.shared().downloadUserRewards { rewards, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let rewards = rewards else { return }
                
                if rewards.isEmpty {
                    DispatchQueue.main.async {
                        self.present(UIAlertController.defaultDialog(title: "This user has no rewards", message: "This user has no rewards - To retrieve rewards, the current user needs to interact with any marker or hunt with rewards"), animated: true, completion: nil)
                    }
                }
                
                self.rewardList = rewards
                
                // Update the table view with the retrieved Rewards
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func getRewardByID(_ sender: Any) {
        
        // Show input dialog to ask for an User Reward ID
        let inputDialog = UIAlertController.inputDialog(title: "Filter Reward by ID", message: "Insert an ID to retrieve the User Reward", defaultValue: "")
        inputDialog.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak inputDialog] (_) in
            
            // Show message if no ID was added
            guard let id = inputDialog?.textFields?[0].text, !id.isEmpty else {
                self.present(UIAlertController.defaultDialog(title: "ID is empty", message: "Write a Reward ID to search for it and see the details"), animated: true, completion: nil)
                return
            }
            
            // Get the ID and try to retrieve the reward
            self.retrieveReward(id)
            
        }))
        present(inputDialog, animated: true, completion: nil)
    }
    
    func retrieveReward(_ id: String) {
        
        // You can retrieve any Rewards (owned or not) by an ID using
        // IARNetworkManager.shared().downloadReward(id)
        // But we recommend that you only show rewards that are owned by the user
        
        // If the user has no rewards, show an alert and do nothing
        if self.rewardList.isEmpty {
            let alert = UIAlertController.defaultDialog(title: "This user has no rewards", message: "This user has no rewards - To retrieve rewards, the current user needs to interact with any marker or hunt with rewards")
            present(alert, animated: true, completion: nil)
            return
        }
        
        // If the user has rewards, try to find the one that matches the ID
        for item in self.rewardList {
            if item.rewardId == id {
                selectedReward = item
                self.showRewardDetails()
                return
            }
        }
        
       // If none is found, show an alert
        let alert = UIAlertController.defaultDialog(title: "This user doesn't have this reward", message: "To retrieve a reward, interact with the corresponding marker or hunt")
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - methods - Navigation
    
    func showRewardDetails(){
        performSegue(withIdentifier: "segueUserRewardDetails", sender: self)
    }
}

// MARK: - Extensions

extension UserRewardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stops the table view from opening multiple new screens when one is selected
        tableView.isUserInteractionEnabled = false
        
        self.selectedReward = self.rewardList[indexPath.row]
        self.showRewardDetails()
    }
}

extension UserRewardsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rewardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reward = self.rewardList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCellIdentifier", for: indexPath) as! PreviewCell
        cell.setupCell(name: reward.rewardName ?? "---", id: reward.rewardId, thumbnailURL: reward.file?.url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
