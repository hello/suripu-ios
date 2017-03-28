//
//  HEMTextFieldCollectionViewCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/16/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMTextFieldCollectionViewCell {
    
    @objc func applyStyle() {
        let aClass = HEMTextFieldCollectionViewCell.self
        let hintColor = SenseStyle.color(aClass: aClass, property: .hintColor)
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.titledTextField?.titleLabel.textColor = hintColor
        self.titledTextField?.backgroundColor = self.backgroundColor
        self.titledTextField?.titleLabel.backgroundColor = self.backgroundColor
        //self.titledTextField?.textField?.applyStyle()
    }
    
}
