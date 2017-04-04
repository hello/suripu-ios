//
//  HEMActivityCoverView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMActivityCoverView {
    
    @objc func applyStyle() {
        let bgColor = SenseStyle.color(group: .activityView, property: .backgroundColor)
        let textColor = SenseStyle.color(group: .activityView, property: .textColor)
        let tintColor = SenseStyle.color(group: .activityView, property: .tintColor)
        self.backgroundColor = bgColor
        self.activityLabel?.textColor = textColor
        self.indicator?.tintColor = tintColor
        self.successMarkView?.tintColor = tintColor
    }
    
}
