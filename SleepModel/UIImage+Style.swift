//
//  UIImage+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/14/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIImage {
    
    func normalIconStyle() -> UIImage {
        return self.tint(property: .tintColor)
    }
    
    func disabledIconStyle() -> UIImage {
        return self.tint(property: .tintDisabledColor)
    }
    
    func highlightedIconStyle() -> UIImage {
        return self.tint(property: .tintHighlightedColor)
    }
    
    @objc func tint(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.set()
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
    @objc fileprivate func tint(property: Theme.ThemeProperty) -> UIImage {
        let color = SenseStyle.color(aClass: UIImage.self, property: property)
        return self.tint(with: color)
    }
    
}
