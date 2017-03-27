//
//  TabPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

class TabPresenter: HEMPresenter {
    
    fileprivate static let highlightedPostFix = "Highlighted"
    fileprivate static let indicatorUnicode = "\u{2022}" // bullet point
    
    weak var tabItem: UITabBarItem!
    fileprivate var iconKey: String?
    fileprivate var iconHighlightedKey: String?
    fileprivate var icon: UIImage?
    fileprivate var iconHighlighted: UIImage?
    fileprivate var title: String?
    fileprivate weak var unreadService: HEMUnreadAlertService?
    fileprivate var checkingForUnread: Bool = false
    
    init(controllers: Array<UIViewController>?, unreadService: HEMUnreadAlertService?) {
        if controllers != nil {
            for controller in controllers! {
                if controller is HEMBaseController {
                    let baseController = controller as! HEMBaseController
                    self.icon = baseController.tabIcon
                    self.iconHighlighted = baseController.tabIconHighlighted
                    break
                }
            }
        }
        self.unreadService = unreadService
        super.init()
    }
    
    init(iconBaseName: String?, title: String?) {
        if iconBaseName != nil {
            self.icon = UIImage(named: iconBaseName!)
            
            let highlightedName = iconBaseName!.appending(TabPresenter.highlightedPostFix)
            self.iconHighlighted = UIImage(named: highlightedName)
            
            self.title = title
        }
        super.init()
    }
    
    init(styleKey: String?, styleHighlightedKey: String?, title: String?) {
        if styleKey != nil && styleHighlightedKey != nil {
            self.iconKey = styleKey
            self.iconHighlightedKey = styleHighlightedKey
            self.icon = SenseStyle.image(aClass: UITabBar.self, propertyName: styleKey!)
            self.iconHighlighted = SenseStyle.image(aClass: UITabBar.self, propertyName: styleHighlightedKey!)
            self.title = title
        }
        super.init()
    }
    
    fileprivate func reloadStyledIcons() {
        guard let key = self.iconKey else {
            return
        }
        
        guard let highlightedKey = self.iconHighlightedKey else {
            return
        }
        
        self.icon = SenseStyle.image(aClass: UITabBar.self, propertyName: key)
        self.iconHighlighted = SenseStyle.image(aClass: UITabBar.self, propertyName: highlightedKey)
        self.reloadIcons()
    }
    
    fileprivate func reloadIcons() {
        if self.iconHighlighted != nil {
            self.iconHighlighted = self.iconHighlighted!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        
        if self.icon != nil {
            self.icon = self.icon!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        
        self.tabItem.image = self.icon
        self.tabItem.selectedImage = self.iconHighlighted
    }
    
    func bind(tabItem: UITabBarItem) {
        self.tabItem = tabItem
        self.reloadIcons()
        self.listenForUnreadUpdates()
        self.checkForUnread()
    }
    
    // MARK: - Presenter Events
    
    override func didChange(_ theme: Theme) {
        super.didChange(theme)
        self.reloadStyledIcons()
    }
    
    override func didAppear() {
        super.didAppear()
        self.updatedUnread()
    }
    
    override func didComeBackFromBackground() {
        super.didComeBackFromBackground()
        self.checkForUnread()
    }
    
    // MARK: - Unread
    
    fileprivate func checkForUnread() {
        guard let service = self.unreadService else {
            return
        }
        
        guard self.checkingForUnread == false else {
            return
        }
        
        self.checkingForUnread = true
        service.update { [weak self] (_: Bool, error: Error?) in
            self?.checkingForUnread = false
        }
    }
    
    fileprivate func listenForUnreadUpdates() {
        guard let service = self.unreadService else {
            return
        }
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(updatedUnread),
                           name: NSNotification.Name(rawValue: kHEMUnreadAlertNotificationUpdate),
                           object: service)
    }
    
    @objc fileprivate func updatedUnread() {
        let hasUnread = self.unreadService?.hasUnread() ?? false
        self.tabItem.title = !self.isVisible && hasUnread ? TabPresenter.indicatorUnicode : nil
    }
    
    // MARK: - Clean up
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
