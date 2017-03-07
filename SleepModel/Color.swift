//
//  Color.swift
//  Sense
//
//  Created by Jimmy Lu on 1/25/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import UIKit

@objc class Color: NSObject {
    
    fileprivate static let resourceName = "colors"
    fileprivate static let hexRadix = 16
    
    fileprivate static let keyHex = "style.color.hex"
    fileprivate static let keyAlpha = "style.color.alpha"
    
    fileprivate static var resource: [String: Any]! {
        return Bundle.read(jsonFileName: resourceName) as? [String: Any]
    }
    
    static func color(hex: UInt!, alpha: CGFloat?) -> UIColor {
        return UIColor.init(red: CGFloat(hex & 0xFF0000 >> 16) / 255.0,
                            green: CGFloat(hex & 0xFF00 >> 8) / 255.0,
                            blue: CGFloat(hex & 0xFF) / 255.0,
                            alpha: alpha ?? 1.0)
    }
    
    static func named(name: String!) -> UIColor {
        guard let definitions = resource else {
            return UIColor.black
        }
        
        guard let info = definitions[name] as? [String: Any] else {
            return UIColor.black
        }
        
        guard let hexText = info[keyHex] as? String else {
            return UIColor.black
        }
        
        guard let hex = UInt(hexText, radix: hexRadix) else {
            return UIColor.black
        }
        
        let alphaNumber = info[keyAlpha] as? NSNumber
        let alpha = (alphaNumber != nil) ? CGFloat(alphaNumber!.floatValue) : CGFloat(1.0)
        return color(hex: hex, alpha: alpha)
    }
    
}

