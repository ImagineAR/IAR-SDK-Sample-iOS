//
//  ARHuntDetailsViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-26.
//

import UIKit
import Foundation
import IAR_Core_SDK

class ARHuntDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var retroactiveContributionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    var hunt: Hunt?
    var selectedMarker: HuntMarker?
    var selectedReward: HuntReward?
    
    // Sections used on the tableView
    let sections = ["Hunt Markers", "Hunt Rewards"]
    
    // Info for threse sections
    var huntMarkerList: [HuntMarker]? = []
    var huntRewardList: [HuntReward]? = []
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if it's trying to show a HuntMarker or a HuntReward
        
        if segue.identifier == "segueARHuntMarkerDetails" {
            // Check to see if there is a selected HuntMarker
            guard let huntMarker = self.selectedMarker else { return }
            
            // Show the HuntMarker details
            if let details = segue.destination as? ARHuntMarkerDetailsViewController {
                details.huntMarker = huntMarker
            }
        }
        
        else if segue.identifier == "segueARHuntRewardDetails" {
            // Check to see if there is a selected HuntReward
            guard let huntReward = self.selectedReward else { return }
            
            // Show the HuntReward details
            if let details = segue.destination as? ARHuntRewardDetailsViewController {
                details.huntReward = huntReward
            }
        }
        
        return
    }

    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "AR Hunt Details"
        
        // TableView setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCellIdentifier")
    }
    
    private func setupInfo() {
        // Check if a Hunt was given when oppening the detail view
        guard let hunt = self.hunt else { return }
        
        // A Hunt has a lot of different properties.
        // It could be used and exposed as you need.
        self.nameLabel.text = hunt.name
        self.idLabel.text = hunt.huntId
        self.setupThumbnailImage(url: hunt.thumbnailUrl)
        self.descriptionLabel.text = hunt.huntDescription ?? "No Description"
        self.setupDate(start: hunt.startDate, end: hunt.endDate)
        self.retroactiveContributionLabel.text = hunt.retroactiveContribution ?
            "Retroactive Contrubution: ON" : "Retroactive Contrubution: OFF"
        
        // Hunt Markers and Hunt Rewards
        self.huntMarkerList = hunt.huntMarkers
        self.huntRewardList = hunt.huntRewards
    }
    
    private func setupThumbnailImage(url: String?) {
        guard let url = url else { return }
        if let thumbnailImageURL = URL(string: url) {
            self.thumbnailImageView.setImageProgressive(with: thumbnailImageURL)
        }
    }
    
    private func setupDate(start: Date?, end: Date?) {
        guard let start = start, let end = end else {
            self.startDateLabel.text = "Start Date: ---"
            self.endDateLabel.text = "End Date: ---"
            return
        }
        
        // Create Date Formatter: 2022-01-26 12:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // Show on View
        self.startDateLabel.text = dateFormatter.string(from: start)
        self.endDateLabel.text = dateFormatter.string(from: end)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func onMoreButton(_ sender: Any) {
        // Hunt descriptions can be 500 characters long.
        // It can contain tips or part of the story you are trying to tell
        let allDescription = UIAlertController.defaultDialog(title: "Hunt Description", message: self.hunt?.huntDescription ?? " --- ")
        present(allDescription, animated: true, completion: nil)
    }
    
    // MARK: - methods - Navigation
    
    func showARHuntRewardDetails() {
        performSegue(withIdentifier: "segueARHuntRewardDetails", sender: self)
    }
    
    func showARHuntMarkerDetails() {
        performSegue(withIdentifier: "segueARHuntMarkerDetails", sender: self)
    }
}

// MARK: - Extensions

extension ARHuntDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stops the table view from opening multiple new screens when one is selected
        tableView.isUserInteractionEnabled = false
        
        // 0 - HuntMarkerList
        if indexPath.section == 0 {
            guard let huntMarkerList = self.huntMarkerList else { return }
            self.selectedMarker = huntMarkerList[indexPath.row]
            self.showARHuntMarkerDetails()
        }
        
        // 0 - HuntRewardList
        else {
            guard let huntRewardList = self.huntRewardList else { return }
            self.selectedReward = huntRewardList[indexPath.row]
            self.showARHuntRewardDetails()
        }
    }
}

extension ARHuntDetailsViewController: UITableViewDataSource {
    
    // Two sections. One for Hunt Markers and another for Hunt Rewards
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 0 - HuntMarkerList
        if section == 0 {
            return self.huntMarkerList?.count ?? 0
        }
        // 1 = HuntRewardList
        else if section == 1 {
            return self.huntRewardList?.count ?? 0
        }
        
        // Default
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCellIdentifier", for: indexPath) as! PreviewCell

        // Hunt Markers
        if indexPath.section == 0 {
            guard let huntMarkerList = self.huntMarkerList else { return cell }
            let huntMarker = huntMarkerList[indexPath.row]
            cell.setupCell(name: huntMarker.marker?.name ?? "", id: huntMarker.huntMarkerId, thumbnailURL: huntMarker.marker?.previewImageUrl)
        }
        
        // Hunt Rewards
        else if indexPath.section == 1 {
            guard let huntRewardList = self.huntRewardList else  { return cell }
            let huntRewad = huntRewardList[indexPath.row]
            cell.setupCell(name: huntRewad.reward?.rewardName ?? "", id: huntRewad.reward?.rewardId ?? "", thumbnailURL: huntRewad.reward?.file?.url)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
