//
//  HEMExpansionHeaderView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/10/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMExpansionHeaderView {
    
    @objc func applyStyle() {
        let myClass = HEMExpansionHeaderView.self
        let bgColor = SenseStyle.color(aClass: myClass, property: .backgroundColor)
        self.backgroundColor = bgColor
        
        let titleColor = SenseStyle.color(aClass: myClass, property: .textColor)
        let titleFont = SenseStyle.font(aClass: myClass, property: .textFont)
        self.titleLabel.textColor = titleColor
        self.titleLabel.font = titleFont
        
        let detailColor = SenseStyle.color(aClass: myClass, property: .detailColor)
        let detailFont = SenseStyle.font(aClass: myClass, property: .detailFont)
        self.subtitleLabel.textColor = detailColor
        self.subtitleLabel.font = detailFont
        
        self.descriptionLabel.textColor = detailColor
        self.descriptionLabel.font = detailFont
        
        if let attributedBody = self.descriptionLabel.attributedText {
            let mutableBody = attributedBody.mutableCopy() as! NSMutableAttributedString
            let attributes = [NSForegroundColorAttributeName : detailColor,
                              NSFontAttributeName : detailFont,
                              NSParagraphStyleAttributeName : NSMutableParagraphStyle.senseStyle()]
            mutableBody.applyAttributes(attributes)
            self.descriptionLabel.attributedText = mutableBody
        }
    }
    
}
