//
//  HEMDeviceCollectionViewCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMDeviceCollectionViewCell {
    
    @objc override func applyStyle() {
        super.applyStyle()
        let aClass = HEMDeviceCollectionViewCell.self
        let font = SenseStyle.font(aClass: aClass, property: .textFont)
        let color = SenseStyle.color(aClass: aClass, property: .textColor)
        let detailFont = SenseStyle.font(aClass: aClass, property: .detailFont)
        let detailColor = SenseStyle.color(aClass: aClass, property: .detailColor)
        
        self.nameLabel.textColor = color
        self.nameLabel.font = font
        self.lastSeenLabel.textColor = color
        self.lastSeenLabel.font = font
        self.property1Label.textColor = color
        self.property1Label.font = font
        self.property2Label.textColor = color
        self.property2Label.font = font
        self.lastSeenValueLabel.textColor = detailColor
        self.lastSeenValueLabel.font = detailFont
        self.property1ValueLabel.textColor = detailColor
        self.property1ValueLabel.font = detailFont
        self.property2ValueLabel.textColor = detailColor
        self.property2ValueLabel.font = detailFont
        self.accessoryImageView.tintColor = SenseStyle.color(aClass: aClass, property: .tintColor)
        self.separator.backgroundColor = SenseStyle.color(aClass: aClass, property: .separatorColor)
        
    }
    
}
