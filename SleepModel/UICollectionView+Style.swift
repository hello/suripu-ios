//
//  UICollectionView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/15/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UICollectionView {
    
    @objc func applyStyle() {
        let aClass = UICollectionView.self
        self.backgroundColor = SenseStyle.color(aClass: aClass, property: .backgroundColor)
        self.superview?.backgroundColor = self.backgroundColor
    }
    
}
