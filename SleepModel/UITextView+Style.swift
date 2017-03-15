//
//  UITextView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UITextView {
    
    @objc func applyStyle() {
        self.applyClassStyle(aClass: UITextView.self)
    }
    
    @objc func applyClassStyle(aClass: AnyClass) {
        guard let attributedText = self.attributedText else {
            self.textColor = SenseStyle.color(aClass: aClass, property: .textColor)
            self.font = SenseStyle.font(aClass: aClass, property: .textFont)
            return
        }
        
        guard let mutableText = attributedText.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        var attributes: [String: Any] = [:]
        attributes[NSParagraphStyleAttributeName] = DefaultBodyParagraphStyle()
        
        if let color = SenseStyle.color(aClass: aClass, property: .textColor) {
            attributes[NSForegroundColorAttributeName] = color
        }
        if let font = SenseStyle.font(aClass: aClass, property: .textFont) {
            attributes[NSFontAttributeName] = font
        }
        
        mutableText.applyAttributes(attributes)
        self.attributedText = mutableText
    }
}
