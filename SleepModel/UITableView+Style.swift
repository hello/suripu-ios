//
//  UITableView+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension UITableView {
    
    @objc func applyGroupStyle(group: SenseStyle.Group) {
        self.backgroundColor = SenseStyle.color(group: group, property: .backgroundColor)
        self.separatorColor = SenseStyle.color(group: group, property: .separatorColor)
        self.tintColor = SenseStyle.color(group: group, property: .tintColor)
        self.superview?.backgroundColor = self.backgroundColor
        self.clipsToBounds = true
        
        let footer = self.tableFooterView
        var footerLabel = footer as? UILabel
        if footerLabel == nil {
            footerLabel = footer?.subviews.first as? UILabel
        }
        
        if footerLabel != nil {
            footerLabel?.textColor = SenseStyle.color(group: group, property: .hintColor)
            footerLabel?.font = SenseStyle.font(group: group, property: .hintFont)
        }
    }
    
    @objc func applyStyle() {
        self.applyGroupStyle(group: .tableView)
    }
    
    @objc func applyFillStyle() {
        self.applyGroupStyle(group: .tableViewFill)
    }
    
}
