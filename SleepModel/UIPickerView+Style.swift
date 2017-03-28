//
//  UIPickerView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/27/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIPickerView {
    
    @objc func applyStyle() {
        self.backgroundColor = SenseStyle.color(aClass: UIPickerView.self,
                                                property: .backgroundColor)
    }
    
}
