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
        
        var key: String {
            switch self {
            case .tableView:
                return "hello.tableview"
            case .listItem:
                return "hello.list.item"
            case .navigationController:
                return "hello.navigation.controller"
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
    
    @objc static func value(group: Group, property: Theme.ThemeProperty) -> Any? {
        return self.theme.value(group: group.key, property: property)
    }
    
}
