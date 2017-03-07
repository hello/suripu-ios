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
    case night = 1
    
    var name: String {
        switch self {
            case .night:
                return "nightTheme"
        }
    }
}

@available(iOS 8.2, *)
@objc class SenseStyle: NSObject {
    
    static let themeKey = "is.hello.app.theme"
    static let theme = Theme()
    
    static func loadSavedTheme() {
        let preferences = SENLocalPreferences.shared()
        guard let themeValue = preferences!.userPreference(forKey: themeKey) as? NSNumber else {
            return
        }
        
        let supportedTheme = SupportedTheme(rawValue: themeValue.intValue)
        theme.load(name: supportedTheme!.name)
    }
    
    static func saveTheme(theme: SupportedTheme) {
        let preferences = SENLocalPreferences.shared()
        preferences!.setUserPreference(theme.hashValue, forKey: themeKey)
    }
    
}
