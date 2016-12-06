//
//  TabPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

class SlideTabPresenter: HEMPresenter {
    
    weak var tabItem: UITabBarItem!
    fileprivate var icon: UIImage?
    fileprivate var title: String?
    
    init(controllers: Array<UIViewController>?) {
        if controllers != nil {
            for controller in controllers! {
                if controller is HEMBaseController {
                    let baseController = controller as! HEMBaseController
                    self.icon = baseController.tabIcon
                    self.title = baseController.tabTitle
                    break
                }
            }
        }
        super.init()
    }
    
    func bind(tabItem: UITabBarItem) {
        tabItem.image = self.icon
        tabItem.title = self.title
        self.tabItem = tabItem
    }
    
}
