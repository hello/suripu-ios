//
//  HEMBasicTableViewCell+Style.swift
//  Sense
//
//  Created by Jimmy Lu on 3/9/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

extension HEMBasicTableViewCell {
    
    @objc override func applyStyle() {
        super.applyStyle()
        let bgColor = SenseStyle.color(group: .listItem, property: .backgroundColor)
        let textColor = SenseStyle.color(group: .listItem, property: .textColor)
        let textFont = SenseStyle.font(group: .listItem, property: .textFont)
        let detailColor = SenseStyle.color(group: .listItem, property: .detailColor)
        let detailFont = SenseStyle.font(group: .listItem, property: .detailFont)
        let separatorColor = SenseStyle.color(group: .listItem, property: .separatorColor)
        self.contentView.backgroundColor = bgColor
        self.backgroundColor = bgColor
        self.customTitleLabel?.textColor = textColor
        self.customTitleLabel?.font = textFont
        self.customDetailLabel?.textColor = detailColor
        self.customDetailLabel?.font = detailFont
        self.customDetailLabel?.backgroundColor = bgColor
        self.customTitleLabel?.backgroundColor = bgColor
        self.customSeparator?.backgroundColor = separatorColor
        self.remoteImageView?.backgroundColor = bgColor
    }
    
    @objc func detail(_ highlighted: Bool) {
        let color: UIColor?
        if highlighted == true  {
            color = SenseStyle.color(group: .listItem, property: .linkColor)
        } else {
            color = SenseStyle.color(group: .listItem, property: .detailColor)
        }
        self.customDetailLabel?.textColor = color
    }
    
    @objc override func applyTintStyle(highlighted: Bool) {
        let property: Theme.ThemeProperty = highlighted == true ? .tintHighlightedColor : .tintColor
        let tintColor = SenseStyle.color(group: .listItemSelection, property: property)
        self.remoteImageView?.tintColor = tintColor
    }
    
}
