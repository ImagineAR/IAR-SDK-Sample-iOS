//
//  DebugLocationCommand.swift
//  IAR_Example
//
//  Created by Rogerio on 2021-09-14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import IAR_Core_SDK

internal class DebugLocationCommand: IARDebugCommandProtocol {
    
    func terminate() {}

    var key: String {
        "location"
    }
    
    var help: String {
        "location [\(arguments.keys.joined(separator: "|"))]"
    }
    
    var manual: String {
        "Location utility. Parameters:\n• info - retuns last location retrieved\n• help - shows this help text"
    }
    
    private typealias ArgumentFunction = () -> String
    private lazy var arguments: [String: ArgumentFunction] = [
        "info": locationInfo,
        "help": executeHelp,
    ]
    
    func execute(args: [String]) -> String {
        guard let firstArg = args.first else {
            return locationInfo()
        }
        
        guard let firstPair = arguments[firstArg] else {
            return "Invalid argument: \(firstArg) - Expected: \(help)"
        }
        
        return firstPair()
    }
    
    private func locationInfo() -> String {
        guard let location = UserDefaults.standard.string(forKey: "SimulatedLocation") else {
            return "No location history available"
        }
        return "Last location in memory: \(location)"
    }
}
