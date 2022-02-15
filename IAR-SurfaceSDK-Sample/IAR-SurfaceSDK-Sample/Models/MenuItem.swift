//
//  MenuItem.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Rogerio on 2021-12-11.
//

import Foundation

public struct MenuItem {
    public let ID: ItemID
    public let Icon: String
    public let Title: String
}

public enum ItemID {
    case locationMarkers
    case onDemandMarkers
    case nfcWrite
    case nfcRead
    case debugTools
    case userManagement
}
