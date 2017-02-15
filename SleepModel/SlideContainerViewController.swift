//
//  SlideContainerViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 12/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import Foundation
import SenseKit

@objc class SlideContainerViewController: HEMBaseController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activity: HEMActivityIndicatorView?
    
    fileprivate weak var shortcutHandler: ShortcutHandler?
    fileprivate var shortcutAction: HEMShortcutAction?
    fileprivate var shortcutActionData: Any?
    fileprivate weak var tabItemPresenter: TabPresenter!
    fileprivate var shortcutHandlerIndex: Int?
    
    var unreadService: HEMUnreadAlertService?
    
    var contentPresenter: SlideContentPresenter? {
        didSet {
            guard contentPresenter != nil else {
                return
            }
            
            guard self.tabItemPresenter == nil else {
                return
            }
            
            let controllers = contentPresenter!.contentControllers
            let tabPresenter = TabPresenter(controllers: controllers,
                                            unreadService: self.unreadService)
            tabPresenter.bind(tabItem: self.tabBarItem)
            self.addPresenter(tabPresenter)
            self.tabItemPresenter = tabPresenter
        }
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentPresenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performShortcutActionIfNeeded()
    }
    
    // MARK: Configuration
    
    fileprivate func configureContentPresenter() {
        guard self.contentPresenter != nil else {
            SENAnalytics.trackWarning(withMessage: "presenter not defined")
            return
        }
        // delegate must be set first, and the activity must be bound before
        // other elements are bound so it can be leveraged
        self.contentPresenter!.visibilityDelegate = self
        self.contentPresenter!.bind(activity: self.activity)
        self.contentPresenter!.bind(navigationBar: self.navigationController?.navigationBar)
        self.contentPresenter!.bind(with: self.shadowView!)
        self.contentPresenter!.bind(scrollView: self.scrollView)

        self.addPresenter(self.contentPresenter!)
    }

}

extension SlideContainerViewController: Scrollable {
    
    func scrollToTop() {
        for controller in self.childViewControllers {
            var mainController = controller
            if mainController is UINavigationController {
                mainController = (mainController as! UINavigationController).topViewController!
            }
            (mainController as? Scrollable)?.scrollToTop()
        }
    }
    
}

extension SlideContainerViewController: SlideContentVisibilityDelegate {
    
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

extension SlideContainerViewController: ShortcutHandler {
    
    fileprivate func performShortcutActionIfNeeded() {
        guard let action = self.shortcutAction else {
            return
        }
        
        guard let handler = self.shortcutHandler else {
            return
        }
        
        self.contentPresenter?.show(controllerIndex: self.shortcutHandlerIndex!)
        
        handler.takeAction(action: action, data: self.shortcutActionData)
        
        self.shortcutHandler = nil
        self.shortcutActionData = nil
        self.shortcutHandlerIndex = 0
        self.shortcutAction = HEMShortcutAction.unknown
    }
    
    func canHandleAction(action: HEMShortcutAction) -> Bool {
        guard self.contentPresenter?.contentControllers.count ?? 0 > 0 else {
            return false
        }
        
        let controllers = self.contentPresenter!.contentControllers!
        var handlerIndex = -1
        
        for (index, controller) in controllers.enumerated() {
            if let handler = controller as? ShortcutHandler {
                if handler.canHandleAction(action: action) == true {
                    self.shortcutHandler = handler
                    self.shortcutAction = action
                    self.shortcutHandlerIndex = index
                    handlerIndex = index
                    break
                }
            }
        }
        
        if handlerIndex >= 0 {
            for (index, controller) in controllers.enumerated() {
                if handlerIndex != index {
                    controller.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        return handlerIndex >= 0
    }
    
    func takeAction(action: HEMShortcutAction, data: Any?) {
        self.shortcutActionData = data
        
        guard let _ = self.scrollView else {
            // delay action until visible
            return
        }
        self.performShortcutActionIfNeeded()
    }
    
}
