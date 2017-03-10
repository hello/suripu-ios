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
    
    @objc enum Group: Int {
        case tableView = 1
        case listItem
        case navigationController
        case warningView
        case activityView
        case controller
        case volumeControl
        case view
        
        var key: String {
            switch self {
            case .view:
                return "sense.view"
            case .tableView:
                return "sense.tableview"
            case .listItem:
                return "sense.list.item"
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
    
    //MARK: - Convenience methods
    
    @objc static func color(group: Group, property: Theme.ThemeProperty) -> UIColor? {
        return self.value(group: group, property: property) as? UIColor
    }
    
    @objc static func color(group: Group, propertyName: String) -> UIColor? {
        return self.theme.value(group: group.key, key: propertyName) as? UIColor
    }
    
    @objc static func font(group: Group, property: Theme.ThemeProperty) -> UIFont? {
        return self.value(group: group, property: property) as? UIFont
    }
    
    @objc static func font(group: Group, propertyName: String) -> UIFont? {
        return self.theme.value(group: group.key, key: propertyName) as? UIFont
    }
    
    @objc static func value(group: Group, property: Theme.ThemeProperty) -> Any? {
        return self.theme.value(group: group.key, property: property)
    }
    
    @objc static func value(group: Group, propertyName: String) -> Any? {
        return self.theme.value(group: group.key, key: propertyName)
    }
    
}
