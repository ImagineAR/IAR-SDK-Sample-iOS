//
//  ARHuntMarkerDetailsViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-02-04.
//

import UIKit
import IAR_Core_SDK

class ARHuntMarkerDetailsViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var detailsTextView: UITextView!
    
    // MARK: - Properties
    
    var huntMarker: HuntMarker?
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupInfo()
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "ARHunt Marker Details"
    }
    
    private func setupInfo() {
        // Check if a Hunt Marker was given when oppening the detail view
        guard let huntMarker = self.huntMarker else { return }
        guard let marker = huntMarker.marker else { return }
        
        self.nameLabel.text = marker.name
        self.idLabel.text = huntMarker.huntMarkerId
        self.setupThumbnailImage(url: marker.previewImageUrl)
        self.detailsTextView.text = huntMarker.printInspection()
    }
    
    private func setupThumbnailImage(url: String?) {
        guard let url = url else { return }
        if let thumbnailImageURL = URL(string: url) {
            self.thumbnailImageView.setImageProgressive(with: thumbnailImageURL)
        }
    }
}
