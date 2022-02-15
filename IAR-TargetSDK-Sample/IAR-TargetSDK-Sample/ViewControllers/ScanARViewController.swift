//
//  ScanARViewController.swift
//  IAR-TargetSDK-Sample
//
//  Created by Julia on 2022-01-10.
//

import UIKit
import IAR_Core_SDK
import IAR_Target_SDK

class ScanARViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var arView: IARView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordProgressView: UIProgressView!
    
    // MARK: - Properties
    
    private var arManager: IARManager?
    private var recorder = IARRecorder()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupPermissions()
        startAR()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Stop IARManager when the view will disappear
        
        stopAR()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Start (or resume) IARManager when the view will appear
        
        startAR()
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setup
    
    func setupView() {
        self.navigationController?.title = "Scan an AR Target"
        
        // Hide while not recording
        self.recordProgressView.isHidden = true
        
        // Pause IARManager when the app is not on focus and resume once it is again.
        NotificationCenter.default.addObserver(self, selector: #selector(pauseAR), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startAR), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
    }
    
    func setupPermissions() {
        // Camera
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            if isGranted {
                print("Camera permission granted")
            } else {
                print( "Camera permission denied - Target AR requires your permission to access the camera")
            }
        }
        
        // Microphone
        AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
            if isGranted {
                print("Microphone permission granted")
            } else {
                print("Microphone permission denied - Target AR requires your permission to access the camera")
            }
        }
    }
    
    
    // MARK: - Methods - IAR Status
    
    @objc func startAR() {
        guard let manager = arManager else {
            self.arManager = IARManager(delegate: self, using: arView)
            return
        }
        manager.resumeAr()
    }
    
    @objc func pauseAR() {
        guard let manager = arManager else {
            return
        }
        manager.pauseAr()
    }
    
    func stopAR() {
        guard let manager = arManager else {
            return
        }
        manager.stopAr()
    }
    
    
    // MARK: - Methods - Screenshot and Recording
    
    @IBAction func onScreenshotButton(_ sender: Any) {
        // Returns an UIImage for the IARView
        let screenshotImage: UIImage = recorder.takeScreenshot(self.arView)
        
        // With that image, it's possible to present a share modal so the user can save or share wherever they want
        let ActivityController = UIActivityViewController(activityItems: [screenshotImage], applicationActivities: nil)
        self.present(ActivityController, animated: true, completion: nil)
    }
    
    @IBAction func onRecordButton(_ sender: Any) {
        startRecording()
    }
    
    func startRecording() {
        recordButton.isEnabled = false
        recorder.startRecordingVideo(using: self.arView)
        
        // For this example, it will stop recording after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.stopRecording()
        }
    }
    
    func stopRecording() {
        recorder.stopRecordingVideo { progress in
            DispatchQueue.main.async {
                // Progress. Use it to show feedback for users
                self.recordProgressView.isHidden = false
                self.recordProgressView.progress = progress.floatValue
            }
        } completion: { url, error in
            DispatchQueue.main.async {
                self.recordButton.isEnabled = true
                self.recordProgressView.isHidden = true
                
                if let error = error {
                    // Handle the error
                    print(error.localizedDescription)
                }
                if let url = url {
                    // With the video URL, it's possible to present a share modal so the user can save or share wherever they want
                    let ActivityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self.present(ActivityController, animated: true, completion: nil)
                }
                
            }
        }
    }
}


// MARK: - Extension IARManagerDelegate

extension ScanARViewController: IARManagerDelegate {
    
    // MARK: - Required delegate methods
    
    // Called when IAR and Vuforia complete initialization
    func manager(_ manager: IARManager, onInitARDone error: Error?) {
        if let error = error {
            print("IAR - Error initializing IARManager - \(error.localizedDescription)")
        }
        print("IAR - Initialized with success")
    }
    
    // Called when an error occurs
    func manager(_ manager: IARManager, onError error: Error) {
        print("IAR - Error: \(error.localizedDescription)")
    }
    
    
    // MARK: - Optional delegate methods
    
    // Called when the marker has a reward to display
    func manager(_ manager: IARManager, markerHasReward marker: Marker) {
        print("IAR - markerHasReward")
    }

    // Called when the reward objects and associated files have been downloaded
    func manager(_ manager: IARManager, didReceive rewards: [Reward]) {
        print("IAR - didReceiveRewards")
    }
    
    // WARNING: THIS METHOD IS DEPRECATED. Use 'didReceiveRewards' instead.
    // Called when the reward object and associated files have been downloaded
    func manager(_ manager: IARManager, didReceive reward: Reward) {
        print("IAR - didReceiveReward")
    }

    // Called to check if the augmentation for the selected target should be rendered
    func manager(_ manager: IARManager, shouldRenderAugmentation targetId: String) -> Bool {
        print("IAR - shouldRenderAugmentation")
        
        return true
    }
    
    // Called when when an image target is recognized
    func manager(_ manager: IARManager, didScanTarget marker: Marker) {
        print("IAR - didScanTarget")
    }

    // Called when the IARView changes its tracking status
    func manager(_ manager: IARManager, onTrackingChanged isTracking: Bool) {
        if isTracking {
            print("IAR - IARView is searching for an image marker")
        } else {
            print("IAR - IARView is NOT searching for an image marker")
        }
    }

    // Callback for the progress of an asset that is being downloaded.
    // Use it to show feedback for users
    func manager(_ manager: IARManager, downloadProgress progress: CGFloat) {
        print("IAR - Download progress: \(progress)")
    }
}
