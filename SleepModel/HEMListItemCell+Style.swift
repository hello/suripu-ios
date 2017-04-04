//
//  HEMLIstItemCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMListItemCell {
    
    @objc override func applyStyle() {
        let itemBgColor = SenseStyle.value(group: .listItem, property: .backgroundColor) as? UIColor
        let itemTextColor = SenseStyle.value(group: .listItem, property: .textColor) as? UIColor
        let itemTextFont = SenseStyle.value(group: .listItem, property: .textFont) as? UIFont
        let itemDetailFont = SenseStyle.value(group: .listItem, property: .detailFont) as? UIFont
        let itemDetailColor = SenseStyle.value(group: .listItem, property: .detailColor) as? UIColor
        self.backgroundColor = itemBgColor
        self.contentView.backgroundColor = itemBgColor
        self.itemLabel?.textColor = itemTextColor
        self.itemLabel?.font = itemTextFont
        self.descriptionLabel?.font = itemDetailFont
        self.descriptionLabel?.textColor = itemDetailColor
    }
    
    @objc override func applyTintStyle(highlighted: Bool) {
        let property: Theme.ThemeProperty = highlighted ? .tintHighlightedColor : .tintColor
        let tintColor = SenseStyle.color(group: .listItemSelection, property: property)
        self.selectionImageView?.tintColor = tintColor
    }
    
}
