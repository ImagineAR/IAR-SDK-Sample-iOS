//
//  MenuController.swift
//  IAR-TargetSDK-Sample
//
//  Created by Rogerio on 2021-12-23.
//

import Foundation
import UIKit

public class MenuController {
    public let menuItems: [MenuItem]
    
    init() {
        menuItems = [
            MenuItem(ID: .userManagement, Icon: "person.fill", Title: "User Management"),
            MenuItem(ID: .userRewards, Icon: "gift.fill", Title: "User Rewards"),
            MenuItem(ID: .locationMarkers, Icon: "location.fill", Title: "Location Markers"),
            MenuItem(ID: .onDemandMarkers, Icon: "square.and.arrow.down.on.square.fill", Title: "On Demand Markers"),
            MenuItem(ID: .arHunts, Icon: "map.fill", Title: "AR Hunts"),
            MenuItem(ID: .debugTools, Icon: "ellipsis.curlybraces", Title: "Debug Tools")
        ]
    }
}
