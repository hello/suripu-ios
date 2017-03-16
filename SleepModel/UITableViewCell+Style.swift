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
        self.backgroundColor = SenseStyle.color(group: .listItem, property: .backgroundColor)
        self.contentView.backgroundColor = self.backgroundColor
        self.textLabel?.textColor = SenseStyle.color(group: .listItem, property: .textColor)
        self.textLabel?.font = SenseStyle.font(group: .listItem, property: .textFont)
        self.detailTextLabel?.textColor = SenseStyle.color(group: .listItem, property: .detailColor)
        self.detailTextLabel?.font = SenseStyle.font(group: .listItem, property: .detailFont)
        self.imageView?.tintColor = SenseStyle.color(group: .listItem, property: .tintColor)
    }
    
    @objc func applyTintStyle(highlighted: Bool) {
        let property: Theme.ThemeProperty = highlighted ? .tintHighlightedColor : .tintColor
        let tintColor = SenseStyle.color(group: .listItemSelection, property: property)
        self.accessoryView?.tintColor = tintColor
    }
    
}
