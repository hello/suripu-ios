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
    
    static func color(string: String!) -> UIColor {
        let hex = string.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                return .black
        }
        return UIColor(red: CGFloat(r) / 255,
                       green: CGFloat(g) / 255,
                       blue: CGFloat(b) / 255,
                       alpha: CGFloat(a) / 255)
    }
    
    static func color(string: String!, alpha: CGFloat!) -> UIColor {
        return self.color(string: string).withAlphaComponent(alpha)
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
        
        let alphaNumber = info[keyAlpha] as? NSNumber
        let alpha = (alphaNumber != nil) ? CGFloat(alphaNumber!.floatValue) : CGFloat(1.0)
        return color(string: hexText, alpha: alpha)
    }
    
}

