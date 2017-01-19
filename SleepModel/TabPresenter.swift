//
//  TabPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

@objc protocol TabIndicatorDelegate: class {
    
    func show(indicator: Bool, in presenter: TabPresenter)
    
}

class TabPresenter: HEMPresenter {
    
    fileprivate static let highlightedPostFix = "Highlighted"
    fileprivate static let indicatorUnicode = "\u{2022}"
    
    weak var tabItem: UITabBarItem!
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
    
    func bind(tabItem: UITabBarItem) {
        if self.iconHighlighted != nil {
            self.iconHighlighted = self.iconHighlighted!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        
        if self.icon != nil {
            self.icon = self.icon!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        
        tabItem.image = self.icon
        tabItem.selectedImage = self.iconHighlighted
        self.tabItem = tabItem
        
        self.listenForUnreadUpdates()
        self.checkForUnread()
    }
    
    // MARK: - Presenter Events
    
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
