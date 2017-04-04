//
//  UICollectionReusableView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UICollectionReusableView {
    
    @objc func applyHeaderFooterStyle() {
        self.backgroundColor = SenseStyle.color(group: .headerFooter, property: .backgroundColor)
    }
    
}
