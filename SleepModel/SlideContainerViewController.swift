//
//  SlideContainerViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc class SlideContainerViewController: HEMBaseController, SlideContentVisibilityDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activity: HEMActivityIndicatorView?
    
    fileprivate weak var tabItemPresenter: TabPresenter!
    var contentPresenter: SlideContentPresenter! {
        didSet {
            guard contentPresenter != nil else {
                return
            }
            
            guard self.tabItemPresenter == nil else {
                return
            }
            
            let controllers = contentPresenter.contentControllers
            let tabPresenter = TabPresenter(controllers: controllers)
            tabPresenter.bind(tabItem: self.tabBarItem)
            self.addPresenter(tabPresenter)
            self.tabItemPresenter = tabPresenter
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentPresenter()
    }
    
    // MARK: Configuration
    
    func configureContentPresenter() {
        guard self.contentPresenter != nil else {
            SENAnalytics.trackWarning(withMessage: "presenter not defined")
            return
        }
        // delegate must be set first, and the activity must be bound before
        // other elements are bound so it can be leveraged
        self.contentPresenter.visibilityDelegate = self
        self.contentPresenter.bind(activity: self.activity)
        self.contentPresenter.bind(navigationBar: self.navigationController?.navigationBar)
        self.contentPresenter.bind(with: self.shadowView!)
        self.contentPresenter.bind(scrollView: self.scrollView)

        self.addPresenter(self.contentPresenter)
    }
    
    // MARK: SlideContentVisibilityDelegate
    
    func addController(controller: UIViewController, from _: SlideContentPresenter?) {
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)
    }
    
    func removeController(controller: UIViewController, from _: SlideContentPresenter?) {
        controller.willMove(toParentViewController: nil)
        controller.removeFromParentViewController()
    }
    
    func update(viewAtIndex: Int, visible: Bool, from _: SlideContentPresenter?) {
        if viewAtIndex < self.childViewControllers.count {
            let controller = self.childViewControllers[viewAtIndex]
            controller.beginAppearanceTransition(visible, animated: true)
            controller.endAppearanceTransition()
        }
    }
}
