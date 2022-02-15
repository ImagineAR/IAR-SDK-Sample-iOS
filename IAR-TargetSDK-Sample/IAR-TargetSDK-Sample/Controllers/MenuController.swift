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
            MenuItem(ID: .scanARTarget, Icon: "camera.viewfinder", Title: "Scan an AR Target"),
            MenuItem(ID: .debugTools, Icon: "ellipsis.curlybraces", Title: "Debug tools"),
            MenuItem(ID: .userManagement, Icon: "person.crop.circle", Title: "User Management"),
        ]
    }
}
