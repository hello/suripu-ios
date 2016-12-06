//
//  SlideContainerViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation

@objc class SlideContainerViewController: HEMBaseController, SlideContentVisibilityDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    weak var tabItemPresenter: SlideTabPresenter!
    weak var contentPresenter: SlideContentPresenter!
    
    var contentControllers: Array<UIViewController>! {
        didSet {
            if self.tabItemPresenter == nil {
                let tabPresenter = SlideTabPresenter(controllers: contentControllers)
                tabPresenter.bind(tabItem: self.tabBarItem)
                self.addPresenter(tabPresenter)
                self.tabItemPresenter = tabPresenter
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurePresenter()
    }
    
    // MARK: Configuration
    
    fileprivate func configurePresenter() {
        var views = Array<UIView>()
        var titles = Array<String>()
        
        for controller in self.contentControllers {
            views.append(controller.view)
            titles.append(self.title(controller: controller))
            self.addChildViewController(controller)
            controller.didMove(toParentViewController: self)
        }
        
        let contentPresenter = SlideContentPresenter(views: views, titles: titles)!
        let navigationBar = self.navigationController?.navigationBar
        if navigationBar != nil {
            contentPresenter.bind(navigationBar: navigationBar)
        }
        
        if self.shadowView != nil {
            contentPresenter.bind(with: self.shadowView!)
        }
        
        contentPresenter.bind(scrollView: self.scrollView)
        contentPresenter.visibilityDelegate = self

        self.addPresenter(contentPresenter)
    }
    
    fileprivate func title(controller: UIViewController!) -> String! {
        var controllerTitle: String!
        if controller.title != nil  {
            controllerTitle = controller.title
        } else if controller is HEMBaseController {
            controllerTitle = (controller as! HEMBaseController).tabTitle
        } else {
            controllerTitle = NSStringFromClass(object_getClass(controller))
        }
        return controllerTitle
    }
    
    // MARK: SlideContentVisibilityDelegate
    
    func update(viewAtIndex: Int, visible: Bool, from: SlideContentPresenter) {
        if viewAtIndex < self.childViewControllers.count {
            let controller = self.childViewControllers[viewAtIndex]
            controller.beginAppearanceTransition(visible, animated: true)
            controller.endAppearanceTransition()
        }
    }
}
