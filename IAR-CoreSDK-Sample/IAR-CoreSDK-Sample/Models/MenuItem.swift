//
//  MenuItem.swift
//  IAR-TargetSDK-Sample
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
    case userManagement
    case userRewards
    case locationMarkers
    case onDemandMarkers
    case arHunts
    case debugTools
}
