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
    
    fileprivate enum ThemeGroup: String {
        case appearance = "style.appearance"
    }
    
    @objc enum ThemeProperty: Int {
        case backgroundColor
        case separatorColor
        case textColor
        case textFont
        case detailFont
        case linkColor
        case detailColor
        case tintColor
        case hintFont
        case hintColor
        case navigationBarTintColor
        case navigationTintColor
        case navigationTitleColor
        case navigationTitleFont
        case navigationIncludeShadow
        case statusBarStyle
        
        var key: String {
            switch self {
                case .backgroundColor:
                    return "style.background.color"
                case .separatorColor:
                    return "style.separator.color"
                case .textColor:
                    return "style.text.color"
                case .textFont:
                    return "style.text.font"
                case .navigationTintColor:
                    return "style.navigation.tint.color"
                case .navigationBarTintColor:
                    return "style.navigation.bar.tint.color"
                case .navigationTitleColor:
                    return "style.navigation.title.color"
                case .navigationTitleFont:
                    return "style.navigation.title.font"
                case .navigationIncludeShadow:
                    return "style.navigation.include.shadow"
                case .statusBarStyle:
                    return "style.status.bar.style"
                case .detailFont:
                    return "style.text.detail.font"
                case .detailColor:
                    return "style.text.detail.color"
                case .hintFont:
                    return "style.text.hint.font"
                case .hintColor:
                    return "style.text.hint.color"
                case .tintColor:
                    return "style.tint.color"
                case .linkColor:
                    return "style.link.color"
            }
        }
    }
 
    fileprivate static let defaultThemeFile = "defaultTheme"

    fileprivate static let keyParent = "style.parent"
    fileprivate static let statusBarLight = "style.status.bar.LIGHT"
    fileprivate static let statusBarDark = "style.status.bar.DARK"
    
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
        self.loadDefault()
        self.load(name: name)
    }
    
    // MARK: - Load
    
    fileprivate func loadProperties(name: String?) -> [String: Any]? {
        guard let file = name else {
            return nil
        }
        return Bundle.read(jsonFileName: file) as? [String: Any]
    }
    
    fileprivate func loadDefault() {
        self.defaultProperties = self.loadProperties(name: Theme.defaultThemeFile)
    }
    
    fileprivate func groupProperties(group: String!) -> [String: Any]? {
        guard let properties = self.themeProperties?[group] as? [String : Any] else {
            return self.defaultProperties[group] as? [String: Any]
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
    
    /**
     Convenience method to retrieve an appearance value defined by the supported
     "style.appearance" group.  This will be used when apply a theme instance
     
     - Parameter property: the themed property to retrieve
     */
    fileprivate func appearanceValue(property: ThemeProperty) -> Any? {
        return self.value(group: ThemeGroup.appearance.rawValue, key: property.key)
    }
    
    // MARK: - Apply
    
    func apply() {
        let app = UIApplication.shared
        let keyWindow = app.delegate?.window
        let rootVC = keyWindow??.rootViewController
        self.apply(viewController: rootVC)
        self.applyApearances()
    }
    
    fileprivate func applyApearances() {
        let navBarTintColor = self.appearanceValue(property: .navigationBarTintColor) as? UIColor
        let navTintColor = self.appearanceValue(property: .navigationTintColor) as? UIColor
        let navTitleColor = self.appearanceValue(property: .navigationTitleColor) as? UIColor
        let navTitleFont = self.appearanceValue(property: .navigationTitleFont) as? UIFont
        let navIncludeShadow = self.appearanceValue(property: .navigationIncludeShadow) as? NSNumber
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = navBarTintColor
        navigationBar.tintColor = navTintColor
        navigationBar.isTranslucent = false
        
        if navIncludeShadow?.boolValue == false {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
        
        var navTitleAttributes: [String: Any] = [:]
        if navTitleColor != nil {
            navTitleAttributes[NSForegroundColorAttributeName] = navTitleColor
        }
        if navTitleFont != nil {
            navTitleAttributes[NSFontAttributeName] = navTitleFont
        }
        navigationBar.titleTextAttributes = navTitleAttributes
        
        let windows = UIApplication.shared.windows
        windows.forEach { (window: UIWindow) in
            window.subviews.forEach({ (view: UIView) in
                view.removeFromSuperview()
                window.addSubview(view)
            })
        }
    }
    
    fileprivate func apply(viewController: UIViewController?) {
        guard let controller = viewController else {
            return
        }
        
        if let navVC = controller as? UINavigationController {
            navVC.viewControllers.forEach({ (controllerInStack: UIViewController) in
                self.apply(viewController: controllerInStack)
            })
        }
        
        if let tabVC = controller as? UITabBarController {
            tabVC.viewControllers?.forEach({ (tabController: UIViewController) in
                self.apply(viewController: tabController)
            })
        }
        
        guard let themedVC = controller as? Themed else {
            return
        }
        
        themedVC.didChange(theme: self)
        controller.childViewControllers.forEach { (child: UIViewController) in
            self.apply(viewController: child)
        }
    }
    
    // MARK: - Retrieving themed values
    
    /**
        Load a theme by name, which should match the theme configuration file.
        Only one custom theme can be loaded at one time, but the default theme
        properties will be used when a style is not defined / overriden in the
        custom theme
     
        - Parameter name: the name of the theme that matches the configuration file name
     */
    @objc func load(name: String?) {
        self.themeProperties = self.loadProperties(name: name)
        self.apply()
    }
    
    /**
        Unloads the custom theme that is applied, if applied.  This is useful
        if the user signs out or changes context that should not support theme
    */
    @objc func unload() {
        self.themeProperties = nil
        self.apply()
    }
    
    /**
        Returned the themed status bar style
     
        - Returns: status bar style specified in theme, or default
    */
    @objc func statusBarStyle() -> UIStatusBarStyle {
        let styleValue = self.appearanceValue(property: .statusBarStyle) as? String
        if styleValue == Theme.statusBarLight {
            return UIStatusBarStyle.default
        } else {
            return UIStatusBarStyle.lightContent
        }
    }
    
    /**
     Convenience method for objective-c code to retrieve the key to extract
     values for since Swift enum variables and functions cannot be accessed
     by objective-c
     
     - Parameter property: the theme property supported
     */
    @objc func key(property: ThemeProperty) -> String {
        return property.key
    }
    
    /**
        Retrieves the themed property value, if loaded, before looking for default
        theme property value.  Themed property determined by style, if not from
        the root theme, then looking at the value from that style map.  If the
        style inherits from the root, it will fallback to the root style if exits
        
        - Parameter name: the name of the property to retrieve value for
     
        - Returns: the value that matches the property specified
    */
    @objc func value(group: String!, key: String!) -> Any? {
        let themedGroupProps = self.themeProperties?[group] as? [String : Any]
        let defaultGroupProps = self.defaultProperties?[group] as? [String: Any]
        let value = themedGroupProps?[key] ?? defaultGroupProps?[key]
        
        if value == nil {
            let themedParentGroup = themedGroupProps?[Theme.keyParent] as? String
            let parentGroup = defaultProperties?[Theme.keyParent] as? String
            if let parentGroupName = themedParentGroup ?? parentGroup {
                // recursively look for parent value, if value not found
                return self.value(group: parentGroupName, key: key)
            }
        }
        
        return self.transform(value: value)
    }
    
    /**
        Convenience method for Swift to retrieve the value for the specified
        style and theme property that is supported
     
        - Parameter group: the group to retrieve value from
        - Returns: the value that matches the property in the group, if any
    */
    func value(group: String!, property: ThemeProperty) -> Any? {
        return self.value(group: group, key: property.key)
    }

}
