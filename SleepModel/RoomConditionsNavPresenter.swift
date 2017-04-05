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

    weak var navDelegate: RoomConditionsNavDelegate?
    weak var navItem: UINavigationItem?
    
    func bind(navItem: UINavigationItem) {
        var settingsIcon = #imageLiteral(resourceName: "settingsIcon")
        settingsIcon = settingsIcon.withRenderingMode(.alwaysTemplate)
        
        let title = NSLocalizedString("current-conditions.title", comment: "room conditions title")
        let width = SenseStyle.value(aClass: UIBarButtonItem.self, property: .sizeWidth) as? NSNumber
        let height = SenseStyle.value(aClass: UIBarButtonItem.self, property: .sizeHeight) as? NSNumber
        let buttonWidth = CGFloat(width?.floatValue ?? 0.0)
        let buttonSize = CGSize(width: buttonWidth, height: CGFloat(height?.floatValue ?? 0.0))
        let buttonLeftInset = buttonWidth - settingsIcon.size.width
        
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
