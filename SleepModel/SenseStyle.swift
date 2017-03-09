//
//  Style.swift
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc enum SupportedTheme: Int {
    case day = 0
    case night
    
    var name: String? {
        switch self {
            case .day:
                return nil // default
            case .night:
                return "nightTheme"
        }
    }
}

@available(iOS 8.2, *)
@objc class SenseStyle: NSObject {
    
    static let themeKey = "is.hello.app.theme"
    static let theme = Theme()
    
    @objc enum Group: Int {
        case tableView = 1
        case listItem
        
        var key: String {
            switch self {
            case .tableView:
                return "hello.tableview"
            case .listItem:
                return "hello.list.item"
            }
        }
    }
    
    @objc static func loadSavedTheme() {
        guard HEMOnboardingService.shared().hasFinishedOnboarding() == true else {
            return // skipping.  themes only apply to in-app
        }
        
        let preferences = SENLocalPreferences.shared()
        guard let themeValue = preferences!.userPreference(forKey: themeKey) as? NSNumber else {
            return
        }

        guard let supportedTheme = SupportedTheme(rawValue: themeValue.intValue) else {
            return // day is default
        }
        
        theme.load(name: supportedTheme.name)
    }
    
    @objc static func saveTheme(theme: SupportedTheme) {
        let preferences = SENLocalPreferences.shared()
        preferences!.setUserPreference(theme.hashValue, forKey: themeKey)
        self.loadSavedTheme()
    }
    
    //MARK: - Convenience methods
    
    @objc static func apply(tableView: UITableView?) {
        guard let view = tableView else {
            return
        }
        
        let separatorColor = Theme.ThemeProperty.separatorColor.key
        let backgroundColor = Theme.ThemeProperty.backgroundColor.key
        let tableViewSeparatorColor = theme.value(group: Group.tableView.key, key: separatorColor) as? UIColor
        let tableViewBgColor = theme.value(group: Group.tableView.key, key: backgroundColor) as? UIColor
        view.backgroundColor = tableViewBgColor
        view.separatorColor = tableViewSeparatorColor
    }
    
    @objc static func apply(listItemCell: HEMListItemCell?) {
        guard let cell = listItemCell else {
            return
        }
        
        let textFont = Theme.ThemeProperty.textFont.key
        let textColor = Theme.ThemeProperty.textColor.key
        let backgroundColor = Theme.ThemeProperty.backgroundColor.key
        let itemBgColor = theme.value(group: Group.listItem.key, key: backgroundColor) as? UIColor
        let itemTextColor = theme.value(group: Group.listItem.key, key: textColor) as? UIColor
        let itemTextFont = theme.value(group: Group.listItem.key, key: textFont) as? UIFont
        cell.backgroundColor = itemBgColor
        cell.contentView.backgroundColor = itemBgColor
        cell.itemLabel.textColor = itemTextColor
        cell.itemLabel.font = itemTextFont
    }
    
}
