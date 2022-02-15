//
//  MenuController.swift
//  IAR-SurfaceSDK-Sample
//
//  Created by Rogerio on 2021-12-23.
//

import Foundation
import UIKit

public class MenuController {
    public let menuItems: [MenuItem]
    
    init() {
        menuItems = [
            MenuItem(ID: .locationMarkers, Icon: "location.fill", Title: "Location Markers"),
            MenuItem(ID: .onDemandMarkers, Icon: "square.and.arrow.down.on.square.fill", Title: "On Demand Markers"),
            MenuItem(ID: .nfcWrite, Icon: "iphone.and.arrow.forward", Title: "NFC - Writing"),
            MenuItem(ID: .nfcRead, Icon: "iphone.badge.play", Title: "NFC - Reading"),
            MenuItem(ID: .debugTools, Icon: "ellipsis.curlybraces", Title: "Debug Tools"),
            MenuItem(ID: .userManagement, Icon: "person.fill", Title: "User Management"),
        ]
    }
}
