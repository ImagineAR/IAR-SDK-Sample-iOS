//
//  log.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2021-08-06.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import IAR_Core_SDK

public func log(_ input: String? = nil) {
    guard let content = input else {
        return
    }
    
    FileLogger.shared.log(content: content)
}
