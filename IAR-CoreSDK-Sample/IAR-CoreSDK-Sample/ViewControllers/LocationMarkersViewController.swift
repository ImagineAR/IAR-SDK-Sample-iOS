//
//  LocationMarkersViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-02-04.
//

import UIKit
import IAR_Core_SDK

class LocationMarkersViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    
    // MARK: - Properties

    var locationMarkerList: [Marker] = []
    var selectedMarker: Marker?
    
    // These can be changed for testing.
    // On a real app, we recommend to take the current location of the user.
    var latitude = 48.35
    var longitude = 99.99
    var radius = 5000.00
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLocation()
        getLocationMarkers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check to see if there is a selected Marker
        guard let marker = self.selectedMarker else { return }
        
        // Show the Marker details
        if segue.identifier == "segueMarkerDetails"{
            if let details = segue.destination as? MarkerDetailsViewController {
                details.marker = marker
            }
        }
    }
    
    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "Location Markers"
        
        // TableView setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCellIdentifier")
    }
    
    private func setupLocation(){
        var simulatedLocation: String = "\(self.latitude);\(self.longitude)"
        
        // Check if there is a simulated location from the Degub tools
        if DebugSettingsController.shared.simulatedLocation {
            simulatedLocation = "\(DebugSettingsController.shared.simulatedLatitude);\(DebugSettingsController.shared.simulatedLongitude)"
        }
        
        // If there is none, get the last simulated location for this device
        else if let location = UserDefaults.standard.string(forKey: "SimulatedLocation") {
                simulatedLocation = location
        }
        
        updateCoordinates(simulatedLocation)
    }
    
    private func updateLocation() {
        UserDefaults.standard.set("\(self.latitude);\(self.longitude)", forKey: "SimulatedLocation")
        self.coordinatesLabel.text = String(format: "Coordinates %.2f;%.2f. Radius: %.2f", self.longitude, self.latitude, self.radius)

    }
    
    
    // MARK: - methods - Location Markers
    
    func getLocationMarkers() {
        // Call to fetch all Location Markers under the current OrgKey
        IARNetworkManager.shared().downloadLocationMarkers(self.latitude, longitude: self.longitude, radius: self.radius) { markers, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let markerList = markers else { return }
                self.locationMarkerList = markerList

                // Update the table view with the retrieved markers.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func onGetMarkersButton(_ sender: Any) {
        // Show input dialog to ask for new lat and long
        
        let inputDialog = UIAlertController.inputDialog(title: "Get markers by location", message: "Enter location coordinates (Lat; Long) separated by ;", defaultValue: "")
        inputDialog.textFields?[0].placeholder = "eg.: 48.35;99.99"
        inputDialog.textFields?[0].keyboardType = .numbersAndPunctuation
        inputDialog.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak inputDialog] (_) in
            
            // Show message if no ID was added
            guard let coordinates = inputDialog?.textFields?[0].text, !coordinates.isEmpty else {
                self.present(UIAlertController.defaultDialog(title: "Field is empty", message: "Write coordinates to retrieve the markers on that location"), animated: true, completion: nil)
                return
            }
            
            // Get the coordinates and try to retrieve the location markers
            self.updateCoordinates(coordinates)
            
        }))
        present(inputDialog, animated: true, completion: nil)
    }
    
    private func updateCoordinates(_ coordinates: String) {
        guard coordinates.split(separator: ";").count == 2 else {
            self.present(UIAlertController.defaultDialog(title: "Invalid input", message: "Latitude and Longitude values need to be separated by ;"), animated: true, completion: nil)
            return
        }
        
        getNewLocation(from: coordinates)
        
        self.updateLocation()
        self.getLocationMarkers()
    }
    
    private func getNewLocation(from stringLocation: String ) {
        UserDefaults.standard.set(stringLocation, forKey: "SimulatedLocation")
        let newCoordinate = stringLocation.split(separator: ";")
        
        self.latitude = Double(newCoordinate[0]) ?? 0.0
        self.longitude = Double(newCoordinate[1]) ?? 0.0
    }
    
    private func onTakeMeThereButton(latitude: Double, longitude: Double) {
        let latitudeString = latitude
        let longitudeString = longitude
        
        self.updateCoordinates("\(latitudeString);\(longitudeString)")
    }
    
    func retrieveMarker(_ id: String) {
        // Will try to find and show the marker by ID
        IARNetworkManager.shared().downloadMarker(id) { marker, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            // If it couldn't find, show a message
            guard let marker = marker else {
                DispatchQueue.main.async {
                    self.present(UIAlertController.defaultDialog(title: "ID not found", message: "We couldn't find a marker using this ID."), animated: true, completion: nil)
                }
                
                // re-enable the user interaction if it faild to open details
                self.tableView.isUserInteractionEnabled = true
                
                return
            }
                
            // Show details for this marker
            self.selectedMarker = marker

            DispatchQueue.main.async {
                self.showMarkerDetails()
            }
        } progressCallback: { progress in
            print(progress)
        }
    }
    
    
    // MARK: - methods - Navigation
    
    func showMarkerDetails() {
        performSegue(withIdentifier: "segueMarkerDetails", sender: self)
    }
    
}

// MARK: - Extensions

extension LocationMarkersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stops the table view from opening multiple new screens when one is selected
        tableView.isUserInteractionEnabled = false
        
        let currentMarker = self.locationMarkerList[indexPath.row]
        
        // To interact with a marker, get it's rewards and move foward in a hunt
        // The method IARNetworkManager.shared().downloadMarker(id) needs to be called
        // Or else it will not count as an interaction
        self.retrieveMarker(currentMarker.markerId)
    }
}

extension LocationMarkersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationMarkerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentMarker = self.locationMarkerList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCellIdentifier", for: indexPath) as! LocationCell
        cell.setupCell(currentMarker, moveToLocationCallback: onTakeMeThereButton(latitude:longitude:))
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
}
