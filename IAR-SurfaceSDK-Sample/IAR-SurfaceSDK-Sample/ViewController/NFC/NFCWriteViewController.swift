//
//  NFCWriteViewController.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Rogerio on 2022-01-27.
//

import Foundation
import UIKit

import IAR_Core_SDK
import IAR_NFC_SDK

class NFCWriteViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var textMarkerID: UITextField!
    @IBOutlet weak var imageWriteTag: UIImageView!
    @IBOutlet weak var imageRandomize: UIImageView!
    @IBOutlet weak var labelResult: UILabel!
    
    private enum RowID: Int {
        case writeTag = 1
        case randomize = 2
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = "Write NFC Tag"
    }
    
    // MARK: - Setup
    private func setupViews() {
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        imageWriteTag.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: smallConfiguration)
        imageRandomize.image = UIImage(systemName: "dice", withConfiguration: smallConfiguration)
    }
    
    // MARK: - Methods
    
    private func randomizeID() {
        textMarkerID.text = UUID().uuidString
    }
    
    private func writeTag(_ markerID: String?) {
        guard let id = markerID, id != "" else {
            let alert = UIAlertController.defaultDialog(title: "Invalid ID",
                                                        message: "Enter some MarkerID before writing to the physical Tag")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if #available(iOS 13.0, *) {
            let tagMarker = MarkerTag(markerId: id, markerType: .ONDEMAND)
            
            NFCController.performAction(.addMarker(marker: tagMarker)) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.labelResult.text = "\(result)"
                }
                print("Result: \(result)")
            }
        } else {
            let alert = UIAlertController.defaultDialog(title: "Unavailable",
                                                        message: "NFC Tags are only available on iOS 13 and above")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowID = RowID(rawValue: indexPath.row) else {
            return
        }
        
        switch rowID {
            case .writeTag:
                writeTag(textMarkerID.text)
            case .randomize:
                randomizeID()
        }
    }
}
