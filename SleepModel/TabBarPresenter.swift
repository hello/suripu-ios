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
    
    func bind(with tabBar: UITabBar!) {
        // hide titles and center tab icons from the controllers
        let topInset = TabBarPresenter.itemInset
        let inset = UIEdgeInsets(top: TabBarPresenter.itemInset, left: 0, bottom: -topInset, right: 0)
        for item in tabBar.items! {
            let titleAttributes: [String: Any] = [NSForegroundColorAttributeName : UIColor.blue6(),
                                                  NSFontAttributeName : UIFont.h7Bold()]
            item.setTitleTextAttributes(titleAttributes, for: UIControlState.normal)
            item.setTitleTextAttributes(titleAttributes, for: UIControlState.selected)
            item.imageInsets = inset
            item.title = nil
        }
    }
}
