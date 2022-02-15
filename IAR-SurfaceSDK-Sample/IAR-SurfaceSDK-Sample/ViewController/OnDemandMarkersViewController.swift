//
//  OnDemandMarkersViewController.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Julia on 2022-01-13.
//

import UIKit
import IAR_Core_SDK
import RappleProgressHUD

class OnDemandMarkersViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties

    var onDemandMarkerList: [Marker] = []
    var selectedMarker: Marker?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getOnDemandMarkers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check to see if there is a selected Marker
        guard let marker = self.selectedMarker else { return }
        
        // Show Surface
        if segue.identifier == "segueSurface"{
            if let surface = segue.destination as? SurfaceViewController {
                surface.marker = marker
            }
        }
    }

    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "On Demand Markers"
        
        // TableView setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCellIdentifier")
    }
    
    // MARK: - methods - On Demand Markers
    
    func getOnDemandMarkers() {
        // Call to fetch all On Demand Markers under the current OrgKey
        IARNetworkManager.shared().downloadOnDemandMarkers { markers, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let markerList = markers else { return }
                self.onDemandMarkerList = markerList
                
                // Update the table view with the retrieved markers.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func getMarkerByID(_ sender: Any) {
        
        // Show input dialog to ask for a Marker ID
        let inputDialog = UIAlertController.inputDialog(title: "Get Marker by ID", message: "Insert an ID to retrieve a Marker", defaultValue: "")
        inputDialog.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak inputDialog] (_) in
            
            // Show message if no ID was added
            guard let id = inputDialog?.textFields?[0].text, !id.isEmpty else {
                self.present(UIAlertController.defaultDialog(title: "ID is empty", message: "Write a Marker ID to search for it"), animated: true, completion: nil)
                return
            }
            
            // Get the ID and try to retrieve the marker
            self.retrieveMarker(id)
            
        }))
        present(inputDialog, animated: true, completion: nil)
    }
    
    func retrieveMarker(_ id: String) {
        // Show loading while retrieving and downloading the marker
        RappleActivityIndicatorView.startAnimating()
        
        // Will try to find and show the marker by ID
        IARNetworkManager.shared().downloadMarker(id) { marker, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            // Hide Loading indicator
            RappleActivityIndicatorView.stopAnimation()
            
            // If it couldn't find, show a message
            guard let marker = marker else {
                DispatchQueue.main.async {
                    self.present(UIAlertController.defaultDialog(title: "ID not found", message: "We couldn't find a marker using this ID."), animated: true, completion: nil)
                }
                
                // re-enable the user interaction if it failed to retrieve the marker
                self.tableView.isUserInteractionEnabled = true
                
                return
            }
                
            self.selectedMarker = marker

            DispatchQueue.main.async {
                self.showSurface()
            }
        } progressCallback: { progress in
            print(progress)
        }
    }
    
    
    // MARK: - methods - Navigation
    
    func showSurface() {
        performSegue(withIdentifier: "segueSurface", sender: self)
    }
    
}

// MARK: - Extensions

extension OnDemandMarkersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stops the table view from opening multiple new screens when one is selected
        tableView.isUserInteractionEnabled = false
        
        let currentMarker = self.onDemandMarkerList[indexPath.row]
        
        // To interact with a marker, get it's rewards and move foward in a hunt
        // The method IARNetworkManager.shared().downloadMarker(id) needs to be called
        // Or else it will not count as an interaction
        self.retrieveMarker(currentMarker.markerId)
    }
}

extension OnDemandMarkersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.onDemandMarkerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentMarker = self.onDemandMarkerList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCellIdentifier", for: indexPath) as! PreviewCell
        cell.setupCell(name: currentMarker.name ?? "---", id: currentMarker.markerId, thumbnailURL: currentMarker.previewImageUrl)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    

}
