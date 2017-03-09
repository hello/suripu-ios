//
//  UINavigationController+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UINavigationController {
    
    @objc func applyStyle() {
        let bgColor = SenseStyle.value(group: .navigationController, property: .backgroundColor) as? UIColor
        self.view.backgroundColor = bgColor
        self.view.clipsToBounds = true
    }
    
}
