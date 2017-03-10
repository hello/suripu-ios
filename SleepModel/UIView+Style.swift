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
        self.backgroundColor = SenseStyle.color(group: .view, propertyName: overlayKey)
    }
    
}
