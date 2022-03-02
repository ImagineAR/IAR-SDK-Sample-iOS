//
//  LocationCell.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Julia on 2022-02-07.
//

import UIKit
import Kingfisher
import IAR_Core_SDK

class LocationCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    // MARK: - Properties
    
    // Passes a function as a parameter, so when the button is pressed,
    // It can call the method stored in this variable.
    var takeMeThereCallback: ((Double, Double) -> ())?
    var markerLatitude: Double?
    var markerLongitude: Double?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // MARK: - Setup
    
    func setupCell(_ marker: Marker, moveToLocationCallback: ((Double, Double) -> ())? = nil) {
        guard let location = marker.location else { return }
        
        self.nameLabel.text = marker.name
        self.idLabel.text = marker.markerId
        self.setupThumbnail(thumbnailUrl: marker.previewImageUrl)
        self.locationDescriptionLabel.text = String(format: "Distance: %.0f", location.distance)
        self.stateLabel.text = location.isNearby() ? "Nearby" : "Far"
        
        self.markerLatitude = location.latitude
        self.markerLongitude = location.longitude
        self.takeMeThereCallback = moveToLocationCallback
    }
    
    private func setupThumbnail(thumbnailUrl: String?) {
        if let url = thumbnailUrl {
            if let previewImageUrl = URL(string: url) {
                self.thumbnailImageView.setImageProgressive(with: previewImageUrl)
                return
            }
        }
    }
    
    
    // MARK: - IBAction
    
    @IBAction func onTakeMeThereButton(_ sender: Any) {
        guard let callback = self.takeMeThereCallback else { return }
        guard let latitude = self.markerLatitude, let longitude = self.markerLongitude else { return }
        callback(latitude, longitude)
    }
}
