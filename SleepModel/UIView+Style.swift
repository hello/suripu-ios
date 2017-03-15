//
//  UIView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/10/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIView {
    
    @objc func applyDisabledOverlayStyle() {
        let overlayKey = "sense.disabled.overlay.color"
        self.backgroundColor = SenseStyle.color(aClass: UIView.self, propertyName: overlayKey)
    }
    
    @objc func applySeparatorStyle() {
        self.backgroundColor = SenseStyle.color(aClass: UIView.self, property: .separatorColor)
    }
    
}
