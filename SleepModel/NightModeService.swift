//
//  NightModeService.swift
//  Sense
//
//  Created by Jimmy Lu on 3/7/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit

class NightModeService: SENService {
    
    static let settingsKey = "is.hello.app.settings.night-mode"
    
    enum Option: String {
        case off = "off"
        case alwaysOn = "always.on"
        case sunsetToSunrise = "sunset.to.sunrise"
        
        func localizedDescription() -> String {
            switch self {
            case .off:
                return NSLocalizedString("settings.night-mode.option.off", comment: "off")
            case .alwaysOn:
                return NSLocalizedString("settings.night-mode.option.always-on", comment: "always on")
            case .sunsetToSunrise:
                return NSLocalizedString("settings.night-mode.option.scheduled", comment: "sunset to sunrise")
            }
        }
        
        static func all() -> [Option] {
            return [Option.off, Option.alwaysOn, Option.sunsetToSunrise]
        }
        
        static func allValues() -> [String] {
            return all().map{ $0.rawValue }
        }
        
        static func fromDescription(description: String) -> Option? {
            for option in all() {
                if option.localizedDescription() == description {
                    return option
                }
            }
            return nil
        }
        
    }
    
    func savedOption() -> Option {
        let key = NightModeService.settingsKey
        let selected = SENLocalPreferences.shared().userPreference(forKey: key) as? String ?? ""
        return Option(rawValue: selected) ?? Option.off
    }
    
    func save(option: Option) {
        let key = NightModeService.settingsKey
        SENLocalPreferences.shared().setUserPreference(option.rawValue, forKey: key)
    }
    
}
