//
//  NFCReadViewController.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Rogerio on 2022-01-27.
//

import Foundation
import UIKit

import IAR_NFC_SDK

class NFCReadViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageReadTag: UIImageView!
    @IBOutlet weak var imageGotoMarker: UIImageView!
    @IBOutlet weak var labelResult: UILabel!
    
    @IBOutlet weak var viewMarkerCell: UIView!
    
    private enum RowID: Int {
        case readTag = 0
        case gotoTag = 1
    }
    
    private var scannedMarker: MarkerTag? {
        didSet {
            viewMarkerCell.isHidden = false
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = "Read NFC Tag"
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        imageReadTag.image = UIImage(systemName: "sensor.tag.radiowaves.forward.fill", withConfiguration: smallConfiguration)
        imageGotoMarker.image = UIImage(systemName: "rectangle.portrait.and.arrow.right.fill", withConfiguration: smallConfiguration)
        viewMarkerCell.isHidden = true
    }
    
    // MARK: - Methods

    private func readTag() {
        if #available(iOS 13.0, *) {
            NFCController.performAction(.readMarker) { [weak self] result in
                guard let marker = try? result.get() else {
                    let message = "NFC reading could not find any marker object"
                    self?.writeResponse(message)
                    return
                }
                
                self?.writeResponse("\(result)")
                print("Result: \(marker)")
                
                self?.scannedMarker = marker
            }
        } else {
            let alert = UIAlertController.defaultDialog(title: "Unavailable",
                                                        message: "NFC Tags are only available on iOS 13 and above")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func gotoTag() {
        guard let tag = scannedMarker else {
            return
        }
        
        // TODO: After surfaceview is ready, call it with this markerID
        print("\(tag)")
    }
    
    private func writeResponse(_ response: String) {
        DispatchQueue.main.async { [weak self] in
            self?.labelResult.text = response
        }
        print(response)

    }

    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowID = RowID(rawValue: indexPath.row) else {
            return
        }
        
        switch rowID {
            case .readTag:
                readTag()
            case .gotoTag:
                gotoTag()
        }

    }
}
