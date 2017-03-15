//
//  UILabel+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/13/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UILabel {
    
    @objc func applyTitleStyle() {
        self.textColor = SenseStyle.color(aClass: UILabel.self, property: .textColor)
    }
    
    @objc func applyDescriptionStyle(override: Bool) {
        guard let attributedText = self.attributedText else {
            self.textColor = SenseStyle.color(aClass: UILabel.self, property: .detailColor)
            self.font = SenseStyle.font(aClass: UILabel.self, property: .detailFont)
            return
        }
        
        guard let mutableText = attributedText.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        var attributes: [String: Any] = [:]
        
        if let color = SenseStyle.color(aClass: UILabel.self, property: .detailColor) {
            attributes[NSForegroundColorAttributeName] = color
        }
        if let font = SenseStyle.font(aClass: UILabel.self, property: .detailFont) {
            attributes[NSFontAttributeName] = font
        }
        
        if attributes.count > 0 {
            if override == true {
                mutableText.addAttributes(attributes, range: NSMakeRange(0, mutableText.length))
            } else {
                mutableText.applyAttributes(attributes)
            }
            self.attributedText = mutableText
        }
        
    }
    
}
