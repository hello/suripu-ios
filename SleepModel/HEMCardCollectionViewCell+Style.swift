//
//  HEMCardCollectionViewCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMCardCollectionViewCell {
    
    @objc func applyStyle() {
        let aClass = HEMCardCollectionViewCell.self
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.contentView.backgroundColor = self.backgroundColor
        self.contentView.layer.borderColor = SenseStyle.color(aClass: aClass, property: .borderColor)?.cgColor
    }
    
}
