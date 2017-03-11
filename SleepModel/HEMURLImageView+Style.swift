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
        self.backgroundColor = SenseStyle.color(group: .remoteImageView,
                                                property: .backgroundColor)
        self.layer.borderColor = SenseStyle.color(group: .remoteImageView,
                                                  property: .borderColor)?.cgColor
        
    }
    
}
