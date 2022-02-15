//
//  UIAlertController.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2021-06-25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public extension UIAlertController {
    
    static func defaultDialog(title: String,
                              message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    static func confirmationDialog(title: String,
                                   message: String,
                                   yesHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesHandler))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

        return alert
    }
    
    static func inputDialog(title: String,
                            message: String,
                            defaultValue: String? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = defaultValue
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        return alert
    }
}
