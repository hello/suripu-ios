//
//  RoomConditionsNavPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

@objc protocol RoomConditionsNavDelegate: class {
    func showSettingsFrom(presenter: RoomConditionsNavPresenter!)
}

class RoomConditionsNavPresenter: HEMPresenter {
    
    static let settingsButtonHeight = CGFloat(44.0)
    weak var navDelegate: RoomConditionsNavDelegate?
    weak var navItem: UINavigationItem?
    
    func bind(navItem: UINavigationItem) {
        let title = NSLocalizedString("current-conditions.title", comment: "room conditions title")
        let settingsIcon = #imageLiteral(resourceName: "settingsIcon")
        let buttonSize = CGSize(width: HEMStyleDefaultNavBarButtonItemWidth,
                                height: RoomConditionsNavPresenter.settingsButtonHeight)
        let buttonLeftInset = HEMStyleDefaultNavBarButtonItemWidth - settingsIcon.size.width
        
        let settingsButton = UIButton.init(type: UIButtonType.custom)
        settingsButton.setImage(settingsIcon, for: UIControlState.normal)
        settingsButton.frame = CGRect(origin: CGPoint.zero, size: buttonSize)
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: buttonLeftInset, bottom: 0, right: 0)
        settingsButton.addTarget(self, action: #selector(didTapOnSettings), for: UIControlEvents.touchUpInside)
        
        navItem.title = title
        navItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        self.navItem = navItem
    }
    
    // MARK: Actions
    
    @objc fileprivate func didTapOnSettings() {
        self.navDelegate?.showSettingsFrom(presenter: self)
    }
    
}
