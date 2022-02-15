//
//  MarkerDetailsViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-29.
//

import UIKit
import Foundation
import IAR_Core_SDK

class MarkerDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    // MARK: - Properties
    
    var marker: Marker?
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInfo()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "Marker Details"
    }
    
    private func setupInfo() {
        // Check if a Marker was given when oppening the detail view
        guard let marker = self.marker else { return }
        
        self.nameLabel.text = marker.name
        self.idLabel.text = marker.markerId
        self.setupThumbnailImage(url: marker.previewImageUrl)
        self.detailsTextView.text = marker.printInspection()
    }
    
    private func setupThumbnailImage(url: String?) {
        guard let url = url else { return }
        if let thumbnailImageURL = URL(string: url) {
            self.thumbnailImageView.setImageProgressive(with: thumbnailImageURL)
        }
    }
}
