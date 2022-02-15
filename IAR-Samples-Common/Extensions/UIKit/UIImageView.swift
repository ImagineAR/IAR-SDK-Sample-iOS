//
//  UIImageView.swift
//  IAR-SDK-Sample
//
//  Created by Rogerio on 2021-06-01.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

public extension UIImageView {
    
    /// Set UIImageView's image using specified URL while taking advantage of Kingfisher local cache and download manager
    func setImage(with url: URL, placeholder: UIImage? = nil, options: [KingfisherOptionsInfoItem]? = nil, completionHandler: ((RetrieveImageResult?) -> Void)? = nil) {
        let options = options ?? [KingfisherOptionsInfoItem.transition(.fade(IARTimeIntervals.short.value))]
        kf.setImage(with: url, placeholder: placeholder, options: options) { result in
            switch result {
                case let .success(value):
                    completionHandler?(value)
                case .failure:
                    completionHandler?(nil)
            }
        }
    }

    /// Calls setImage while updaing image using progressive download
    func setImageProgressive(with url: URL, placeholder: UIImage? = nil, completionHandler: ((RetrieveImageResult?) -> Void)? = nil) {
        let progressive = ImageProgressive(isBlur: true, isFastestScan: true, scanInterval: 0)
        let options = [
            KingfisherOptionsInfoItem.transition(.fade(IARTimeIntervals.short.value)),
            KingfisherOptionsInfoItem.progressiveJPEG(progressive),
        ]
        setImage(with: url, placeholder: placeholder, options: options, completionHandler: completionHandler)
    }
}

public enum IARTimeIntervals {
    case zero
    case short
    case custom(TimeInterval)

    public var value: TimeInterval {
        switch self {
            case .zero: return 0
            case .short: return 0.15
            case let .custom(value): return value
        }
    }

    public var dispatchValue: DispatchTimeInterval {
        .milliseconds(Int(value * Double(1000)))
    }
}
