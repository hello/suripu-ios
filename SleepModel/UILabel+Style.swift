//
//  UILabel+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/13/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UILabel {
    
    fileprivate func apply(fontProperty: Theme.ThemeProperty, colorProperty: Theme.ThemeProperty, override: Bool) {
        self.textColor = SenseStyle.color(aClass: UILabel.self, property: colorProperty)
        self.font = SenseStyle.font(aClass: UILabel.self, property: fontProperty)
        
        guard let mutableText = self.attributedText?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        let font = SenseStyle.font(aClass: UILabel.self, property: fontProperty)
        let color = SenseStyle.color(aClass: UILabel.self, property: colorProperty)
        let attributes: [String: Any] = [NSForegroundColorAttributeName : color,
                                         NSFontAttributeName : font]
        
        if attributes.count > 0 {
            if override == true {
                mutableText.addAttributes(attributes, range: NSMakeRange(0, mutableText.length))
            } else {
                mutableText.applyAttributes(attributes)
            }
            self.attributedText = mutableText
        }
    }
    
    @objc func applyTitleStyle() {
        self.textColor = SenseStyle.color(aClass: UILabel.self, property: .textColor)
        self.font = SenseStyle.font(aClass: UILabel.self, property: .textFont)
    }
    
    @objc func applyDescriptionStyle(override: Bool) {
        self.apply(fontProperty: .detailFont, colorProperty: .detailColor, override: override)
    }
    
    @objc func applyHintStyle() {
        self.apply(fontProperty: .hintFont, colorProperty: .hintColor, override: false)
    }
    
}
