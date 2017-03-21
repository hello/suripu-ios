//
//  HEMURLImageView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/10/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMURLImageView {
    
    @objc func applyStyle() {
        let aClass = HEMURLImageView.self
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.layer.borderColor = SenseStyle.color(aClass: aClass, property: .borderColor).cgColor
    }
    
}
