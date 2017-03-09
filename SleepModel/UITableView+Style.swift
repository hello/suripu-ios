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
        self.backgroundColor = SenseStyle.color(group: .tableView, property: .backgroundColor)
        self.separatorColor = SenseStyle.color(group: .tableView, property: .separatorColor)
        self.tintColor = SenseStyle.color(group: .tableView, property: .tintColor)
        self.superview?.backgroundColor = self.backgroundColor
        self.clipsToBounds = true
        
        let footer = self.tableFooterView
        var footerLabel = footer as? UILabel
        if footerLabel == nil {
            footerLabel = footer?.subviews.first as? UILabel
        }
        
        if footerLabel != nil {
            footerLabel?.textColor = SenseStyle.color(group: .tableView, property: .hintColor)
            footerLabel?.font = SenseStyle.font(group: .tableView, property: .hintFont)
        }
    }
    
}
