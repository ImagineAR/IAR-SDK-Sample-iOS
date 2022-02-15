//
//  PreferencesController.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2021-06-24.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public class PreferencesController {
    
    public static let shared = PreferencesController()
    
    private enum PreferenceKeys: String {
        case externalUserID
        case isGuest
    }
    
    public var externalUserID: String? {
        get {
            Self.value(defaultValue: nil, forKey: PreferenceKeys.externalUserID.rawValue)
        }
        set {
            Self.value(value: newValue, forKey: PreferenceKeys.externalUserID.rawValue)
        }
    }
    
    public var isGuest: Bool {
        get {
            Self.value(defaultValue: true, forKey: PreferenceKeys.isGuest.rawValue)
        }
        set {
            Self.value(value: newValue, forKey: PreferenceKeys.isGuest.rawValue)
        }
    }
    
    fileprivate init() {}
    
    public static func value<T>(defaultValue: T, forKey key: String, postfixKey: String? = nil) -> T {
        let preferences = UserDefaults.standard
        let processedKey = key + (postfixKey ?? "")
        return preferences.object(forKey: processedKey) == nil ? defaultValue : preferences.object(forKey: processedKey) as! T
    }

    public static func value(value: Any?, forKey key: String, postfixKey: String? = nil) {
        UserDefaults.standard.set(value, forKey: key + (postfixKey ?? ""))
        UserDefaults.standard.synchronize()
    }
}
