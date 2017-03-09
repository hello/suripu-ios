//
//  UITableViewCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    @objc func applyStyle() {
        let itemBgColor = SenseStyle.value(group: .listItem, property: .backgroundColor) as? UIColor
        let itemTextColor = SenseStyle.value(group: .listItem, property: .textColor) as? UIColor
        let itemTextFont = SenseStyle.value(group: .listItem, property: .textFont) as? UIFont
        let itemDetailFont = SenseStyle.value(group: .listItem, property: .detailFont) as? UIFont
        let itemDetailColor = SenseStyle.value(group: .listItem, property: .detailColor) as? UIColor
        self.backgroundColor = itemBgColor
        self.contentView.backgroundColor = itemBgColor
        self.textLabel?.textColor = itemTextColor
        self.textLabel?.font = itemTextFont
        self.detailTextLabel?.textColor = itemDetailColor
        self.detailTextLabel?.font = itemDetailFont
    }
    
}
