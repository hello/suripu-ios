//
//  Style.swift
//  Sense
//
//  Created by Jimmy Lu on 1/26/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit
import UIKit

@available(iOS 8.2, *)
@objc class SenseStyle: NSObject {
    
    static let themeKey = "is.hello.app.theme"
    static let theme = Theme()
    
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
    
    @objc enum ConditionStyle: Int {
        case alert = 0
        case warning
        case ideal
        
        var key: String {
            switch self {
            case .alert:
                return "sense.alert"
            case .warning:
                return "sense.warning"
            case .ideal:
                return "sense.ideal"
            }
        }
    }
    
    @objc enum Group: Int {
        case tableView = 1
        case tableViewFill
        case listItem
        case listItemSelection
        case navigationController
        case warningView
        case activityView
        case controller
        case volumeControl
        case remoteImageView
        case condition
        case collectionViewFill
        case headerFooter
        case attributedString
        case action
        
        var key: String {
            switch self {
            case .tableView:
                return "sense.tableview"
            case .tableViewFill:
                return "sense.tableview.fill"
            case .listItem:
                return "sense.list.item"
            case .listItemSelection:
                return "sense.list.item.selection"
            case .navigationController:
                return "sense.navigation.controller"
            case .warningView:
                return "sense.warning.view"
            case .activityView:
                return "sense.activity.cover.view"
            case .controller:
                return "sense.controller"
            case .volumeControl:
                return "sense.volume.control"
            case .remoteImageView:
                return "sense.remote.image.view"
            case .condition:
                return "sense.condition"
            case .collectionViewFill:
                return "sense.collectionview.fill"
            case .headerFooter:
                return "sense.header.or.footer"
            case .attributedString:
                return "sense.attributed.string"
            case .action:
                return "sense.action"
            }
            
        }
    }
    
    @objc static func loadSavedTheme() {
        guard HEMOnboardingService.shared().hasFinishedOnboarding() == true else {
            return theme.apply() // apply default
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
    
    //MARK: - Colors
    
    @objc static func color(aClass: AnyClass, property: Theme.ThemeProperty) -> UIColor? {
        return self.theme.value(aClass: aClass, key: property.key) as? UIColor
    }
    
    @objc static func color(aClass: AnyClass, propertyName: String) -> UIColor? {
        return self.theme.value(aClass: aClass, key: propertyName) as? UIColor
    }
    
    @objc static func color(group: Group, property: Theme.ThemeProperty) -> UIColor? {
        return self.value(group: group, property: property) as? UIColor
    }
    
    @objc static func color(group: Group, propertyName: String) -> UIColor? {
        return self.theme.value(group: group.key, key: propertyName) as? UIColor
    }
    
    //MARK: - Fonts
    
    @objc static func font(aClass: AnyClass, property: Theme.ThemeProperty) -> UIFont? {
        return self.theme.value(aClass: aClass, key: property.key) as? UIFont
    }
    
    @objc static func font(group: Group, property: Theme.ThemeProperty) -> UIFont? {
        return self.value(group: group, property: property) as? UIFont
    }
    
    @objc static func font(group: Group, propertyName: String) -> UIFont? {
        return self.theme.value(group: group.key, key: propertyName) as? UIFont
    }
    
    //MARK: - Value
    
    @objc static func value(group: Group, property: Theme.ThemeProperty) -> Any? {
        return self.theme.value(group: group.key, property: property)
    }
    
    @objc static func value(group: Group, propertyName: String) -> Any? {
        return self.theme.value(group: group.key, key: propertyName)
    }
    
    //MARK: - Color based on condition
    
    @objc static func color(condition: SENCondition, defaultColor: UIColor?) -> UIColor? {
        switch condition {
            case .alert:
                return self.color(group: .condition, propertyName: ConditionStyle.alert.key)
            case .warning:
                return self.color(group: .condition, propertyName: ConditionStyle.warning.key)
            case .ideal:
                return self.color(group: .condition, propertyName: ConditionStyle.ideal.key)
            default:
                return defaultColor
        }
    }
    
}
