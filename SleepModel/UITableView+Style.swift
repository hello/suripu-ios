//
//  UITableView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UITableView {
    
    @objc func applyStyle() {
        self.backgroundColor = SenseStyle.value(group: .tableView, property: .backgroundColor) as? UIColor
        self.separatorColor = SenseStyle.value(group: .tableView, property: .separatorColor) as? UIColor
        self.tintColor = SenseStyle.value(group: .tableView, property: .tintColor) as? UIColor
        self.superview?.backgroundColor = self.backgroundColor
        
        let footer = self.tableFooterView
        var footerLabel = footer as? UILabel
        if footerLabel == nil {
            footerLabel = footer?.subviews.first as? UILabel
        }
        
        if footerLabel != nil {
            footerLabel?.textColor = SenseStyle.value(group: .tableView, property: .hintColor) as? UIColor
            footerLabel?.font = SenseStyle.value(group: .tableView, property: .hintFont) as? UIFont
        }
    }
    
}
