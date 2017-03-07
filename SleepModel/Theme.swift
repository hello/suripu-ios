//
//  Theme.swift
//  Sense
//
//  Created by Jimmy Lu on 1/25/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 8.2, *)
@objc class Theme: NSObject {
    
    @objc enum ThemeProperty: Int {
        case navTitleColor = 1
        case navTitleFont
        
        var key: String {
            switch self {
            case .navTitleColor:
                return "style.appearance.navigation.title.color"
            case .navTitleFont:
                return "style.appearance.navigation.title.font"
            }
        }
    }
 
    fileprivate static let defaultThemeFile = "defaultTheme"
    
    fileprivate static let keyRoot = "style.theme" // required
    fileprivate static let keyParent = "style.parent"
    
    fileprivate static let refColor = "@color"
    fileprivate static let refFont = "@font"
    fileprivate static let refSeparator = "/"
    
    fileprivate var defaultProperties: [String: Any]!
    fileprivate var themeProperties: [String: Any]?
    
    override init() {
        super.init()
        self.loadDefault()
    }
    
    convenience init(name: String!) {
        self.init()
        self.load(name: name)
    }
    
    // MARK: - Load
    
    fileprivate func loadProperties(name: String!) -> [String: Any]? {
        return Bundle.read(jsonFileName: name) as? [String: Any]
    }
    
    fileprivate func loadDefault() {
        self.defaultProperties = self.loadProperties(name: Theme.defaultThemeFile)
    }
    
    /**
        Load a theme by name, which should match the theme configuration file.
        Only one custom theme can be loaded at one time, but the default theme
        properties will be used when a style is not defined / overriden in the
        custom theme
     
        - Parameter name: the name of the theme that matches the configuration file name
    */
    @objc func load(name: String!) {
        self.themeProperties = self.loadProperties(name: name)
    }
    
    // MARK: - Values
    
    /**
        Convenience method for objective-c code to retrieve the key to extract
        values for since Swift enum variables and functions cannot be accessed
        by objective-c
     
        - Parameter property: the theme property supported
    */
    @objc func key(property: ThemeProperty) -> String {
        return property.key
    }
    
    fileprivate func styleProperties(style: String?) -> [String: Any]? {
        let styleName = style ?? Theme.keyRoot
        guard let properties = self.themeProperties?[styleName] as? [String : Any] else {
            return self.defaultProperties[styleName] as? [String: Any]
        }
        return properties
    }
    
    fileprivate func transform(value: Any?) -> Any? {
        guard let valueString = value as? String else {
            return value
        }
        
        if valueString.hasPrefix(Theme.refColor) == true {
            return self.color(value: valueString)
        } else if valueString.hasPrefix(Theme.refFont) == true {
            return self.font(value: valueString)
        } else {
            return valueString
        }
    }
    
    /**
        Retrieves the themed property value, if loaded, before looking for default
        theme property value.  Themed property determined by style, if not from
        the root theme, then looking at the value from that style map.  If the
        style inherits from the root, it will fallback to the root style if exits
        
        - Parameter name: the name of the property to retrieve value for
     
        - Returns: the value that matches the property specified
    */
    @objc func value(style: String?, name: String!) -> Any? {
        let styleProperties = self.styleProperties(style: style)
        let parentStyleName = styleProperties?[Theme.keyParent] as? String
        let defaultRootProps = self.defaultProperties[Theme.keyRoot] as? [String: Any]
        let value = styleProperties?[name] ?? defaultRootProps?[name]
        
        if value == nil && parentStyleName != nil {
            // recursively look for parent value, if value not found
            return self.value(style: parentStyleName, name: name)
        }
        
        return self.transform(value: value)
    }
    
    fileprivate func rootProperties() -> [String: Any]? {
        var rootProperties = self.themeProperties?[Theme.keyRoot] as? [String: Any]
        if rootProperties == nil {
            rootProperties = self.defaultProperties[Theme.keyRoot] as? [String: Any]
        }
        return rootProperties
    }
    
    fileprivate func color(value: String?) -> UIColor? {
        let colorParts = value?.components(separatedBy: Theme.refSeparator)
        var color: UIColor? = nil
        if colorParts?.count == 2 && colorParts![0] == Theme.refColor {
            color = Color.named(name: colorParts![1])
        }
        return color
    }
    
    fileprivate func font(value: String?) -> UIFont? {
        let fontParts = value?.components(separatedBy: Theme.refSeparator)
        var font: UIFont? = nil
        if fontParts?.count == 2 && fontParts![0] == Theme.refFont {
            font = Font.named(name: fontParts![1])
        }
        return font
    }
    
    // MARK: - Apply
    
    fileprivate func apply() {
        let properties = self.rootProperties()

        var navTitleAttributes: [String: Any] = [:]
        
        let navBarTitleColorValue = properties?[ThemeProperty.navTitleColor.key] as? String
        if let navBarTitleColor = self.color(value: navBarTitleColorValue) {
            navTitleAttributes[NSForegroundColorAttributeName] = navBarTitleColor
        }
        
        let navBarTitleFontValue = properties?[ThemeProperty.navTitleFont.key] as? String
        if let navBarTitleFont = self.font(value: navBarTitleFontValue) {
            navTitleAttributes[NSFontAttributeName] = navBarTitleFont
        }
        
        if navTitleAttributes.count > 0 {
            let navBarAppearance = UINavigationBar.appearance()
            navBarAppearance.titleTextAttributes = navTitleAttributes
        }

    }
    
}
