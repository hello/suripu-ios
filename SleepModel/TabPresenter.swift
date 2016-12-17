//
//  TabPresenter.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

class TabPresenter: HEMPresenter {
    
    static let highlightedPostFix = "Highlighted"
    
    weak var tabItem: UITabBarItem!
    fileprivate var icon: UIImage?
    fileprivate var iconHighlighted: UIImage?
    fileprivate var title: String?
    
    init(controllers: Array<UIViewController>?) {
        if controllers != nil {
            for controller in controllers! {
                if controller is HEMBaseController {
                    let baseController = controller as! HEMBaseController
                    self.icon = baseController.tabIcon
                    self.iconHighlighted = baseController.tabIconHighlighted
                    self.title = baseController.tabTitle
                    break
                }
            }
        }
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
        tabItem.title = self.title
        tabItem.selectedImage = self.iconHighlighted
        self.tabItem = tabItem
    }
    
}
