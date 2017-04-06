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
        case backgroundColor
        case separatorColor
        case titleFont
        case titleColor
        case textColor
        case textFont
        case detailFont
        case linkColor
        case detailColor
        case tintColor
        case tintDisabledColor
        case tintHighlightedColor
        case hintFont
        case hintColor
        case includeShadow
        case statusBarStyle
        case primaryButtonTextFont
        case primaryButtonTextColor
        case primaryButtonTextHighlightedColor
        case primaryButtonTextDisabledColor
        case secondaryButtonTextFont
        case secondaryButtonTextColor
        case secondaryButtonTextHighlightedColor
        case secondaryButtonTextDisabledColor
        case borderColor
        case borderHighlightedColor
        case barTintColor
        case translucent
        case backgroundHighlightedColor
        case backgroundDisabledColor
        case textDisabledColor
        case textHighlightedColor
        case iconImage
        case iconHighlightedImage
        case keyboardAppearance
        
        var key: String {
            switch self {
                case .keyboardAppearance:
                    return "style.keyboard.appearance"
                case .iconImage:
                    return "style.icon.image"
                case .iconHighlightedImage:
                    return "style.highlighted.image"
                case .titleFont:
                    return "style.title.font"
                case .titleColor:
                return "style.title.color"
                case .backgroundColor:
                    return "style.background.color"
                case .backgroundHighlightedColor:
                    return "style.background.highlighted.color"
                case .backgroundDisabledColor:
                    return "style.background.disabled.color"
                case .separatorColor:
                    return "style.separator.color"
                case .textColor:
                    return "style.text.color"
                case .textDisabledColor:
                    return "style.text.disabled.color"
                case .textHighlightedColor:
                    return "style.text.highlighted.color"
                case .textFont:
                    return "style.text.font"
                case .includeShadow:
                    return "style.include.shadow"
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
                case .tintDisabledColor:
                    return "style.tint.disabled.color"
                case .tintHighlightedColor:
                    return "style.tint.highlighted.color"
                case .linkColor:
                    return "style.link.color"
                case .primaryButtonTextFont:
                    return "style.primary.button.text.font"
                case .primaryButtonTextColor:
                    return "style.primary.button.text.color"
                case .primaryButtonTextHighlightedColor:
                    return "style.primary.button.text.highlighted.color"
                case .primaryButtonTextDisabledColor:
                    return "style.primary.button.text.disabled.color"
                case .secondaryButtonTextFont:
                    return "style.secondary.button.text.font"
                case .secondaryButtonTextColor:
                    return "style.secondary.button.text.color"
                case .secondaryButtonTextHighlightedColor:
                    return "style.secondary.button.text.highlighted.color"
                case .secondaryButtonTextDisabledColor:
                    return "style.secondary.button.text.disabled.color"
                case .borderColor:
                    return "style.border.color"
                case .borderHighlightedColor:
                    return "style.border.highlighted.color"
                case .barTintColor:
                    return "style.bar.tint.color"
                case .translucent:
                    return "style.translucent"
            }
        }
    }
 
    fileprivate static let defaultThemeFile = "defaultTheme"
    fileprivate static let appGroup = "style.app"

    fileprivate static let classPrefix = "#"
    fileprivate static let keyParent = "style.group.parent"
    fileprivate static let statusBarLight = "style.status.bar.LIGHT"
    fileprivate static let statusBarDark = "style.status.bar.DARK"
    fileprivate static let refColor = "@color"
    fileprivate static let refFont = "@font"
    fileprivate static let refImage = "@image"
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
        self.load(name: name, auto: true)
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
        } else if valueString.hasPrefix(Theme.refImage) == true {
            return self.image(value: valueString)
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
    
    fileprivate func image(value: String?) -> UIImage? {
        let imageParts = value?.components(separatedBy: Theme.refSeparator)
        var image: UIImage? = nil
        if imageParts?.count == 2 && imageParts![0] == Theme.refImage {
            image = UIImage(named: imageParts![1])
        }
        return image
    }
    
    // MARK: - Apply
    
    func apply(auto: Bool) {
        let app = UIApplication.shared
        let keyWindow = app.delegate?.window
        let rootVC = keyWindow??.rootViewController
        self.applyApearances()
        self.apply(viewController: rootVC, auto: auto)
    }
    
    fileprivate func applyApearances() {
        self.applyNavigationBarApperance()
        self.applyToolbarAppearance()
        self.applyTabBarAppearance()
        self.applyBarButtonItemAppearance()
        self.applySwitchAppearance()
        
        let windows = UIApplication.shared.windows
        windows.forEach { (window: UIWindow) in
            window.subviews.forEach({ (view: UIView) in
                view.removeFromSuperview()
                window.addSubview(view)
            })
        }
    }
    
    fileprivate func applyTabBarAppearance() {
        let tabBar = UITabBar.appearance()
        let translucent = self.value(aClass: UITabBar.self, property: .translucent) as? NSNumber
        tabBar.isTranslucent = translucent?.boolValue ?? false
        tabBar.barTintColor = self.value(aClass: UITabBar.self, property: .barTintColor) as? UIColor
        tabBar.tintColor = self.value(aClass: UITabBar.self, property: .tintColor) as? UIColor
    }
    
    fileprivate func applyNavigationBarApperance() {
        let aClass = UINavigationBar.self
        let translucent = self.value(aClass: aClass, property: .translucent) as? NSNumber
        let shadow = self.value(aClass: aClass, property: .includeShadow) as? NSNumber
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = self.value(aClass: aClass, property: .barTintColor) as? UIColor
        navigationBar.tintColor = self.value(aClass: aClass, property: .tintColor) as? UIColor
        navigationBar.isTranslucent = translucent?.boolValue ?? false
        
        if shadow?.boolValue == false {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
        }
        
        var navTitleAttributes: [String: Any] = [:]
        if let navTitleColor = self.value(aClass: aClass, property: .textColor) as? UIColor {
            navTitleAttributes[NSForegroundColorAttributeName] = navTitleColor
        }
        if let navTitleFont = self.value(aClass: aClass, property:. textFont) as? UIFont {
            navTitleAttributes[NSFontAttributeName] = navTitleFont
        }
        navigationBar.titleTextAttributes = navTitleAttributes
    }
    
    fileprivate func applyToolbarAppearance() {
        let toolbar = UIToolbar.appearance()
        let translucent = self.value(aClass: UIToolbar.self, property: .translucent) as? NSNumber
        toolbar.isTranslucent = translucent?.boolValue ?? false
        toolbar.barTintColor = self.value(aClass: UIToolbar.self, property: .barTintColor) as? UIColor
        toolbar.tintColor = self.value(aClass: UIToolbar.self, property: .tintColor) as? UIColor
    }
    
    fileprivate func applyBarButtonItemAppearance() {
        let barButtonItem = UIBarButtonItem.appearance()
        barButtonItem.tintColor = self.value(aClass: UIBarButtonItem.self, property: .tintColor) as? UIColor
        
        let button = UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        button.tintColor = barButtonItem.tintColor
    }
    
    fileprivate func applySwitchAppearance() {
        let switchControl = UISwitch.appearance()
        switchControl.onTintColor = self.value(aClass: UISwitch.self, property: .tintHighlightedColor) as? UIColor
    }
    
    fileprivate func apply(viewController: UIViewController?, auto: Bool) {
        guard let controller = viewController else {
            return
        }
        
        var viewControllers: [UIViewController]?
        if let navVC = controller as? UINavigationController {
            viewControllers = navVC.viewControllers
            viewControllers?.forEach({ (controllerInStack: UIViewController) in
                self.apply(viewController: controllerInStack, auto: auto)
            })
        }
        
        if let tabVC = controller as? UITabBarController {
            viewControllers = tabVC.viewControllers
            viewControllers?.forEach({ (tabController: UIViewController) in
                self.apply(viewController: tabController, auto: auto)
            })
        }
        
        guard let themedVC = controller as? Themed else {
            return
        }
        
        themedVC.didChange(theme: self, auto: auto)
        controller.childViewControllers.forEach { (child: UIViewController) in
            if viewControllers == nil || viewControllers!.contains(child) == false {
                self.apply(viewController: child, auto: auto)
            }
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
    @objc func load(name: String?, auto: Bool) {
        self.themeProperties = self.loadProperties(name: name)
        self.apply(auto: auto)
    }
    
    /**
        Unloads the custom theme that is applied, if applied.  This is useful
        if the user signs out or changes context that should not support theme
    */
    @objc func unload(auto: Bool) {
        self.themeProperties = nil
        self.apply(auto: auto)
    }
    
    /**
        Returned the themed status bar style
     
        - Returns: status bar style specified in theme, or default
    */
    @objc func statusBarStyle() -> UIStatusBarStyle {
        let styleValue = self.value(group: Theme.appGroup, property: .statusBarStyle) as? String
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
            let parentGroup = defaultGroupProps?[Theme.keyParent] as? String
            if let parentGroupName = themedParentGroup ?? parentGroup {
                // recursively look for parent value, if value not found
                return self.value(group: parentGroupName, key: key)
            }
        }
        
        return self.transform(value: value)
    }

    /**
        Convenience method for Swift to retrieve the value specified for the class
        and a supported property
     
        - Parameter aClass: the class of values to retireve
        - Parameter property: the natively supported property
        - Returns: the value that matches the property in the class
     */
    func value(aClass: AnyClass!, property: ThemeProperty) -> Any? {
        return self.value(aClass: aClass, key: property.key)
    }
    
    /**
        Convenience method for Swift to retrieve the value specified for the class
     
        - Parameter aClass: the class of values to retireve
        - Returns: the value that matches the property in the class
     */
    func value(aClass: AnyClass!, key: String!) -> Any? {
        let fullClassName = NSStringFromClass(aClass)
        let groupName = Theme.classPrefix.appending(fullClassName)
        return self.value(group: groupName, key: key)
    }
    
    /**
        Convenience method for Swift to retrieve the value for the specified
        style and theme property that is supported
     
        - Parameter group: the group to retrieve value from
        - Returns: the value that matches the property in the group
    */
    func value(group: String!, property: ThemeProperty) -> Any? {
        return self.value(group: group, key: property.key)
    }

}
