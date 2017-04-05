//
//  NSMutableParagraphStyle+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 4/4/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension NSMutableParagraphStyle {
    
    @objc static func senseStyle() -> NSMutableParagraphStyle {
        let style = self.default.mutableCopy() as! NSMutableParagraphStyle
        let lineHeightKey = "sense.paragraph.line.height"
        if let lineHeight = SenseStyle.value(aClass: self, propertyName: lineHeightKey) as? NSNumber {
            let lineHeightFloat = CGFloat(lineHeight)
            style.maximumLineHeight = lineHeightFloat
            style.minimumLineHeight = lineHeightFloat
        }
        return style    
    }
    
}
