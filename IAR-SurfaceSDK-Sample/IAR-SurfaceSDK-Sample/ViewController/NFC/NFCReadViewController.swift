//
//  NFCReadViewController.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Rogerio on 2022-01-27.
//

import Foundation
import UIKit

import IAR_Core_SDK
import IAR_NFC_SDK
import RappleProgressHUD

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
                
                DispatchQueue.main.async {
                    self?.scannedMarker = marker
                }
            }
        } else {
            let alert = UIAlertController.defaultDialog(title: "Unavailable",
                                                        message: "NFC Tags are only available on iOS 13 and above")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func gotoTag() {
        guard let tag = scannedMarker else {
            let alert = UIAlertController.defaultDialog(title: "No markers scanned",
                                                        message: "Scan a valid NFC tag first")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        print("NFC Tag information: \(tag)")
        tableView.isUserInteractionEnabled = false
        
        retrieveMarker(tag.id)
    }
    
    private func writeResponse(_ response: String) {
        DispatchQueue.main.async { [weak self] in
            self?.labelResult.text = response
        }
        print(response)

    }
    
    func retrieveMarker(_ id: String) {
        // Show loading while retrieving and downloading the marker
        RappleActivityIndicatorView.startAnimating()
        
        // Will try to find and show the marker by ID
        IARNetworkManager.shared().downloadMarker(id) { [weak self] marker, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            // Hide Loading indicator
            RappleActivityIndicatorView.stopAnimation()
            
            // If it couldn't find, show a message
            guard let marker = marker else {
                DispatchQueue.main.async {
                    self?.present(UIAlertController.defaultDialog(title: "ID not found", message: "We couldn't find a marker using this ID."), animated: true, completion: nil)
                }
                
                // re-enable the user interaction if it failed to retrieve the marker
                self?.tableView.isUserInteractionEnabled = true
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let surfaceViewController = storyboard.instantiateViewController(identifier: "SurfaceViewController") as? SurfaceViewController else {
                return
            }

            surfaceViewController.marker = marker
            self?.present(surfaceViewController, animated: true)
        } progressCallback: { progress in
            print(progress)
        }
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
