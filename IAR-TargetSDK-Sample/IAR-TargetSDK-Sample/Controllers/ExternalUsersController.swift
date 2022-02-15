//
//  ExternalUsersController.swift
//  IAR-TargetSDK-Sample
//
//  Created by Rogerio on 2022-01-13.
//

import Foundation
import IAR_Core_SDK

public class ExternalUsersController {
    
    public enum ExternalUsersErrors: LocalizedError {
        case alreadyLoggedInWithUser
        
        public var errorDescription: String? {
            switch self {
                case .alreadyLoggedInWithUser:
                    return "Can't login with the same user that is currently logged in"
            }
        }
    }
    
    public static let shared = ExternalUsersController()
    
    public typealias UserCompletion = (Error?, String?) -> Void
    
    public var userId: String? {
        get {
            PreferencesController.shared.externalUserID
        }
    }
    
    public var isGuest: Bool {
        get {
            PreferencesController.shared.isGuest
        }
        set {
            PreferencesController.shared.isGuest = newValue
        }
    }
    
    // Prevent others from instantiating this singleton directly
    fileprivate init() {}
    
    /// Loads currently stored user
    /// Remarks: requires a valid license assigned to IARNetwork manager
    /// as the method will create an guest session
    public func loadCurrentUser(completion: UserCompletion? = nil) {
        if let currentlyStoredUserId = PreferencesController.shared.externalUserID {
            IARNetworkManager.shared().setExternalUserId(currentlyStoredUserId, clearCache: false)
            let fromSDK = IARNetworkManager.shared().externalUserId()
            log("Loading saved user: \(currentlyStoredUserId) - SDK: \(fromSDK)")
            completion?(nil, currentlyStoredUserId)
        } else {
            // null user - first time execution - will provide an guest session
            log("No user on file - starting guest session...")
            guestSession(completion: completion)
        }
    }
    
    public func logout(completion: UserCompletion? = nil) {
        IARNetworkManager.shared().clearCache()
        guestSession(completion: completion)
        AnalyticsController.shared.sendLogout()
    }
    
    public func createNewUser(with externalUserId: String, completion: UserCompletion? = nil) {
        IARNetworkManager.shared().createExternalUserId(externalUserId) { [weak self] createdUserId, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                completion?(error, nil)
            } else {
                guard let returnedUserId = createdUserId else {
                    return
                }
                
                let finishingClosure = {
                    self.setExternalUserId(userId: returnedUserId, clearCache: false)
                    self.isGuest = false
                }
                
                if self.isGuest {
                    guard let previousUserId = PreferencesController.shared.externalUserID else {
                        finishingClosure()
                        completion?(error, externalUserId)
                        return
                    }
                    
                    IARNetworkManager.shared().migrateData(from: previousUserId, to: returnedUserId) { error in
                        if let error = error {
                            log("Failed to migrate data: \(error.localizedDescription)")
                            completion?(error, nil)
                        } else {
                            finishingClosure()
                            completion?(error, externalUserId)
                        }
                    }
                } else {
                    finishingClosure()
                    completion?(error, externalUserId)
                }
            }
            
            AnalyticsController.shared.sendCreateUser(automatic: false)
        }
    }
    
    public func login(with externalUserId: String, completion: UserCompletion? = nil) {
        guard externalUserId.lowercased() != PreferencesController.shared.externalUserID?.lowercased() else {
            log("Can't login: Attempt to login with same user as the current one")
            completion?(ExternalUsersErrors.alreadyLoggedInWithUser, nil)
            return
        }
        
        if self.isGuest {
            // if current session was guest, migrates data
            IARNetworkManager.shared().migrateData(from: PreferencesController.shared.externalUserID!, to: externalUserId) { [weak self] error in
                guard let self = self else {
                    return
                }
                
                self.isGuest = false
                
                // if not, just change the userId and clear cache
                self.setExternalUserId(userId: externalUserId, clearCache: true)
                completion?(error, externalUserId)
            }
        } else {
            // Should call logout first
            log("Can't login: logout from active session first")
        }
        
        AnalyticsController.shared.sendLogin(login: .emailPassword)
    }
    
    private func guestSession(completion: UserCompletion? = nil) {
        let guestUserId = UUID().uuidString
        IARNetworkManager.shared().createExternalUserId(guestUserId) { [weak self] createdUserId, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                log("Failed to create UserID: \(error.localizedDescription)")
                completion?(error, nil)
            } else if let userId = createdUserId {
                log("New guest UserID: \(userId)")
                
                self.setExternalUserId(userId: userId, clearCache: true)
                self.isGuest = true
                completion?(nil, userId)
            }
        }
        
        AnalyticsController.shared.sendCreateUser(automatic: true)
    }
    
    private func setExternalUserId(userId: String, clearCache: Bool = false) {
        // Sets variable on th live network manager - this does not persist the value anywhere but in the instance
        IARNetworkManager.shared().setExternalUserId(userId, clearCache: true)
        
        // Persists the user id in NSUserDefaults (developer can choose any storage medium,
        // such as keychain, realm, sqllite, ...)
        PreferencesController.shared.externalUserID = userId
    }
    
    public func sampleRegenerate(shouldMigrate: Bool = false, newUserId: String, stayGuest: Bool, completion: UserCompletion? = nil) {
        let currentUserId = PreferencesController.shared.externalUserID!
        
        IARNetworkManager.shared().createExternalUserId(newUserId) { [weak self] createdUserId, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                log("Failed to create UserID: \(error.localizedDescription)")
                completion?(error, nil)
            } else if let userId = createdUserId {
                self.setExternalUserId(userId: userId, clearCache: true)
                self.isGuest = stayGuest
                
                if shouldMigrate {
                    IARNetworkManager.shared().migrateData(from: currentUserId, to: userId) { _ in
                        completion?(nil, userId)
                    }
                } else {
                    completion?(nil, userId)
                }
            }
        }
        
        AnalyticsController.shared.sendCreateUser(automatic: true)
    }
}
