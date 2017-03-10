//
//  UIViewController+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UIViewController {
    
    @objc func applyStyle() {
        let bgColor = SenseStyle.value(group: .controller, property: .backgroundColor) as? UIColor
        self.view.backgroundColor = bgColor
        self.view.clipsToBounds = true
    }
    
}
