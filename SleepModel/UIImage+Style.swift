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
        return self.tint(with: .tintColor)
    }
    
    func disabledIconStyle() -> UIImage {
        return self.tint(with: .tintDisabledColor)
    }
    
    func highlightedIconStyle() -> UIImage {
        return self.tint(with: .tintHighlightedColor)
    }
    
    fileprivate func tint(with property: Theme.ThemeProperty) -> UIImage {
        guard let color = SenseStyle.color(aClass: UIImage.self, property: property) else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.set()
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
    
}
