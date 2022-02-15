//
//  PreviewCell.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-14.
//

import UIKit
import Kingfisher

class PreviewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    // MARK: - Setup
    
    func setupCell(name: String, id: String, thumbnailURL: String? = nil) {
        
        self.nameLabel.text = name
        self.idLabel.text = id
        self.setupThumbnail(thumbnailUrl: thumbnailURL)
    }
    
    private func setupThumbnail(thumbnailUrl: String?) {
        if let url = thumbnailUrl {
            if let previewImageUrl = URL(string: url) {
                self.thumbnailImageView.kf.setImage(with: previewImageUrl)
                return
            }
        }
    }
}
