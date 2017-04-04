//
//  TabBarPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 1/18/17.
//  Copyright © 2017 Hello. All rights reserved.
//

import Foundation

class TabBarPresenter: HEMPresenter {
    
    fileprivate static let itemInset = CGFloat(6)
    fileprivate weak var tabBar: UITabBar?
    
    func bind(with tabBar: UITabBar!) {
        self.tabBar = tabBar
        self.adjustInsets()
    }
    
    func adjustInsets() {
        guard let tabBar = self.tabBar else {
            return
        }
        // hide titles and center tab icons from the controllers
        let aClass = UITabBar.self
        let color = SenseStyle.color(aClass: aClass, property: .titleColor)
        let font = SenseStyle.font(aClass: aClass, property: .titleFont)
        let topInset = TabBarPresenter.itemInset
        let inset = UIEdgeInsets(top: TabBarPresenter.itemInset, left: 0, bottom: -topInset, right: 0)
        for item in tabBar.items! {
            let titleAttributes: [String: Any] = [NSForegroundColorAttributeName : color,
                                                  NSFontAttributeName : font]
            item.setTitleTextAttributes(titleAttributes, for: UIControlState.normal)
            item.setTitleTextAttributes(titleAttributes, for: UIControlState.selected)
            item.imageInsets = inset
            item.title = nil
        }
    }
}
