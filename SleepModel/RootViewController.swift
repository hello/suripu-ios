//
//  RootViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 11/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import UIKit
import SenseKit

@objc class RootViewController: HEMBaseController {
    
    static let overlayAlpha = CGFloat(0.7)
    static let animationDuration = TimeInterval(0.5)
    var statusBarVisible = true
    
    // MARK: Public Methods
    
    @objc static func currentRootViewController() -> RootViewController? {
        let applicationDelegate = UIApplication.shared.delegate
        let applicationWindow = applicationDelegate?.window
        return applicationWindow!!.rootViewController as? RootViewController
    }
    
    // MARK: Status Bar

    @objc func hideStatusBar() {
        self.statusBarVisible = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func showStatusBar() {
        self.statusBarVisible = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func isStatusBarHidden() -> Bool {
        return self.prefersStatusBarHidden
    }

    // MARK: View Controller Overrides
    
    override var prefersStatusBarHidden: Bool {
        return self.statusBarVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForSystemEvents()
        self.launchInitialController()
    }
    
    override func viewDidBecomeActive() {
        super.viewDidBecomeActive()
        HEMAppUsage.incrementUsage(forIdentifier: HEMAppUsageAppLaunched)
        SENAnalytics.track(kHEMAnalyticsEventAppLaunched)
    }
    
    override func viewDidEnterBackground() {
        super.viewDidEnterBackground()
        SENAnalytics.track(kHEMAnalyticsEventAppClosed)
    }
    
    // MARK: Public Methods
    
    @objc public func mainViewController() -> MainViewController? {
        return self.childViewControllers.first as? MainViewController
    }

    // MARK: Notification Events
    
    private func listenForSystemEvents() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(didSignIn),
                           name: NSNotification.Name.SENAuthorizationServiceDidAuthorize,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(didFinishOnboarding),
                           name: NSNotification.Name(rawValue: HEMOnboardingNotificationComplete),
                           object: nil)
        center.addObserver(self,
                           selector: #selector(didSignOut),
                           name: NSNotification.Name.SENAuthorizationServiceDidDeauthorize,
                           object: nil)
        center.addObserver(self,
                           selector: Selector(("reactToShortcut:")),
                           name: nil,
                           object: HEMShortcutService.shared())
    }
    
    @objc private func didSignIn() {
        if HEMOnboardingService.shared().hasFinishedOnboarding() {
            showMainApp()
        }
    }
    
    @objc private func didSignOut() {
        showOnboarding()
    }
    
    @objc private func didFinishOnboarding() {
        showMainApp()
    }
    
    // TODO: react to shortcut
    @objc private func reactToShortcut(notification: Notification) {
        
    }
    
    // MARK: Onboarding vs Main
    
    private func launchInitialController() {
        if HEMOnboardingService.shared().hasFinishedOnboarding() {
            showMainApp()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let service = HEMOnboardingService.shared()
        let checkpoint = service.onboardingCheckpoint()
        let controller = HEMOnboardingController.controller(for: checkpoint, force: false)
        if (controller != nil) {
            launchController(controller: controller!)
        } else {
            let message = "attempt to launch onboarding with no controller"
            SENAnalytics.trackError(withMessage: message)
        }
    }
    
    private func showMainApp() {
        launchController(controller: MainViewController())
    }
    
    private func launchController(controller: UIViewController) {
        let currentController = self.childViewControllers.first
        if object_getClass(currentController) == object_getClass(controller) {
            return
        }
        
        let showMain = controller is MainViewController
        let containerFrame = self.view.bounds
        let containerHeight = containerFrame.size.height
        
        self.addChildViewController(controller)
        
        var controllerFrame = controller.view.frame
        controllerFrame.origin.y = !showMain ? containerHeight : 0
        controller.view.frame = self.view.bounds
        self.view.addSubview(controller.view)
        
        if currentController == nil {
            controller.didMove(toParentViewController: self)
        } else {
            // onboarding is show as if it's a modal by sliding up / down with
            // a dim overlay over the view
            let startAlpha = showMain ? 0 : RootViewController.overlayAlpha
            let endAlpha = showMain ? RootViewController.overlayAlpha : 0
            let overlay = UIView(frame: self.view.bounds)
            overlay.backgroundColor = UIColor.black
            overlay.alpha = startAlpha
            currentController!.willMove(toParentViewController: nil)
            currentController!.view.addSubview(overlay)
            
            UIView.animate(withDuration: RootViewController.animationDuration, animations: {
                overlay.alpha = endAlpha
                
                var currentFrame = currentController!.view.frame
                currentFrame.origin.y = !showMain ? 0 : containerHeight
                currentController!.view.frame = currentFrame

            }, completion: { (finished: Bool) in
                currentController!.view.removeFromSuperview()
                currentController! .removeFromParentViewController()
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    // MARK: Clean Up
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
