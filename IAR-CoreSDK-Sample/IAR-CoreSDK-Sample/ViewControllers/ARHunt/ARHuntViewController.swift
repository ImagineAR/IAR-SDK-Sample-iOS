//
//  ARHuntViewController.swift
//  IAR-CoreSDK-Sample
//
//  Created by Julia on 2022-01-24.
//

import UIKit
import IAR_Core_SDK

class ARHuntViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties

    var huntList: [Hunt] = []
    var selectedHunt: Hunt?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getARHunts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check to see if there is a selected Hunt
        guard let hunt = self.selectedHunt else { return }
        
        // Show the Hunt details
        if segue.identifier == "segueARHuntDetails"{
            if let details = segue.destination as? ARHuntDetailsViewController {
                details.hunt = hunt
            }
        }
    }

    
    // MARK: - Setup
    
    private func setupView() {
        // Navigation setup
        self.navigationController?.title = "AR Hunts"
        
        // TableView setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "PreviewCell", bundle: nil), forCellReuseIdentifier: "PreviewCellIdentifier")
    }
    
    
    // MARK: - methods - ARHunts
    
    func getARHunts() {
        // Call to fetch all ARHunts under the current OrgKey
        IARNetworkManager.shared().retrieveHunts { hunts, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let hunts = hunts else { return }
                self.huntList = hunts
                
                // Update the table view with the retrieved ARHunts.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func getARHuntByID(_ sender: Any) {
        let inputDialog = UIAlertController.inputDialog(title: "Get ARHunt by ID", message: "Insert an ID to retrieve the ARHunt", defaultValue: "")
        inputDialog.addAction(UIAlertAction(title: "Go", style: .default, handler: { [weak inputDialog] (_) in
            
            // Show message if no ID was added
            guard let id = inputDialog?.textFields?[0].text, !id.isEmpty else {
                self.present(UIAlertController.defaultDialog(title: "ID is empty", message: "Write an ARHunt ID to search for it and see the details"), animated: true, completion: nil)
                return
            }
            
            // Get the ID and try to retrieve the hunt
            self.retrieveHunt(id)
            
        }))
        present(inputDialog, animated: true, completion: nil)
    }
    
    func retrieveHunt(_ id: String) {
        // Will try to find and show the hunt by ID
        IARNetworkManager.shared().retrieveHunt(id) { hunt, error in
            if let error = error {
                self.present(UIAlertController.defaultDialog(title: "ID not found", message: "We couldn't find a hunt using this ID. - Error: \(error.localizedDescription)"), animated: true, completion: nil)
            }
            
            else {
                // If it couldn't find, show a message
                guard let hunt = hunt else {
                    DispatchQueue.main.async {
                        self.present(UIAlertController.defaultDialog(title: "ID not found", message: "We couldn't find a hunt using this ID."), animated: true, completion: nil)
                    }
                    
                    // re-enable the user interaction if it faild to open details
                    self.tableView.isUserInteractionEnabled = true
                    
                    return
                }

                // Show details for this Hunt
                self.selectedHunt = hunt
                
                DispatchQueue.main.async {
                    self.showHuntDetails()
                }
            }
        }
    }
    
    
    // MARK: - methods - Navigation
    
    func showHuntDetails(){
        performSegue(withIdentifier: "segueARHuntDetails", sender: self)
    }
}

// MARK: - Extensions

extension ARHuntViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Stops the table view from opening multiple new screens when one is selected
        tableView.isUserInteractionEnabled = false
        
        self.selectedHunt = self.huntList[indexPath.row]
        self.showHuntDetails()
    }
}

extension ARHuntViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.huntList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentHunt = self.huntList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewCellIdentifier", for: indexPath) as! PreviewCell
        cell.setupCell(name: currentHunt.name ?? "---", id: currentHunt.huntId, thumbnailURL: currentHunt.thumbnailUrl)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
