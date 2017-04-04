//
//  HEMActionButton+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/13/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMActionButton {
    
    @objc override func applyStyle() {
        super.applyStyle()
        let aClass = HEMActionButton.self
        self.setBackgroundColor(SenseStyle.color(aClass: aClass, property: .backgroundColor), for: UIControlState.normal)
        self.setBackgroundColor(SenseStyle.color(aClass: aClass, property: .backgroundDisabledColor), for: UIControlState.disabled)
        self.setBackgroundColor(SenseStyle.color(aClass: aClass, property: .backgroundHighlightedColor), for: UIControlState.highlighted)
        self.titleLabel?.font = SenseStyle.font(aClass: aClass, property: .textFont)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textColor), for: UIControlState.normal)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textDisabledColor), for: UIControlState.disabled)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textHighlightedColor), for: UIControlState.highlighted)
    }
    
}
