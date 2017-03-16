//
//  UIButton+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/14/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIButton {
    
    @objc func applyStyle() {
        let aClass = UIButton.self
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.titleLabel?.font = SenseStyle.font(aClass: aClass, property: .textFont)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textColor), for: UIControlState.normal)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textDisabledColor), for: UIControlState.disabled)
        self.setTitleColor(SenseStyle.color(aClass: aClass, property: .textHighlightedColor), for: UIControlState.highlighted)
    }
    
}
