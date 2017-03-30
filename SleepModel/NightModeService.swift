//
//  NightModeService.swift
//  Sense
//
//  Created by Jimmy Lu on 3/7/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import SenseKit
import Solar

class NightModeService: SENService {
    
    static let settingsKey = "is.hello.app.settings.night-mode"
    static let settingsLatKey = "is.hello.app.settings.nm.latitude" // Number
    static let settingsLongKey = "is.hello.app.settings.nm.longitude" // Number
    
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
        guard option != self.savedOption() else {
            return
        }
        
        let key = NightModeService.settingsKey
        SENLocalPreferences.shared().setUserPreference(option.rawValue, forKey: key)
        
        switch (option) {
            case .off:
                SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.day, auto: false)
            case .alwaysOn:
                SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.night, auto: false)
            case .sunsetToSunrise:
                if self.isSunset() == true {
                    SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.night, auto: false)
                } else {
                    SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.day, auto: false)
                }
                break
        }
    }
    
    @objc func loadTheme(override: Bool) {
        switch self.savedOption() {
            case .sunsetToSunrise:
                guard override == true else {
                    return
                }
                
                if self.isSunset() == true {
                    SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.night, auto: true)
                } else {
                    SenseStyle.saveTheme(theme: SenseStyle.SupportedTheme.day, auto: true)
                }
            default:
                SenseStyle.loadSavedTheme(auto: true)
        }
    }
    
    //MARK: Scheduling
    
    fileprivate func isSunset() -> Bool {
        let latKey = NightModeService.settingsLatKey
        let lonKey = NightModeService.settingsLongKey
        let preferences = SENLocalPreferences.shared()!
        
        guard let latitude = preferences.userPreference(forKey: latKey) as? NSNumber else {
            return false
        }
        
        guard let longitude = preferences.userPreference(forKey: lonKey) as? NSNumber else {
            return false
        }
        
        // Solar calculates time for next day's sunrise + sunset so must grab yesterday's
        // calculation and compare that to today
        guard let tonightSolar = Solar.init(for: NSDate().previousDay(),
                                            latitude: latitude.doubleValue,
                                            longitude: longitude.doubleValue) else {
            return false
        }
        
        guard let tomorrowSolar = Solar.init(for: NSDate().nextDay(),
                                             latitude: latitude.doubleValue,
                                             longitude: longitude.doubleValue) else {
            return false
        }
        
        guard let sunset = tonightSolar.sunset else {
            return false
        }
        
        guard let sunrise = tomorrowSolar.sunrise else {
            return false
        }
    
        let startOfDay = sunrise.timeIntervalSince1970
        let endOfDay = sunset.timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        let isBeforeSunrise = currentTime < startOfDay
        let isAfterSunset = currentTime >= endOfDay
        return isAfterSunset && isBeforeSunrise
    }
    
    func scheduleForSunset(latitude: Double, longitude: Double) {
        let latKey = NightModeService.settingsLatKey
        let lonKey = NightModeService.settingsLongKey
        let preferences = SENLocalPreferences.shared()!
        preferences.setUserPreference(NSNumber(floatLiteral: latitude), forKey: latKey)
        preferences.setUserPreference(NSNumber(floatLiteral: longitude), forKey: lonKey)
        self.save(option: .sunsetToSunrise)
    }
    
}
