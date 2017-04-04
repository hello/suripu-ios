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
        let aClass = UIViewController.self
        let bgColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.view.backgroundColor = bgColor
        self.view.clipsToBounds = true
    }
    
}
