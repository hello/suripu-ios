//
//  MainViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 11/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import UIKit
import SenseKit

@objc enum MainTab : Int {
    case Timeline = 0
    case Trends
    case Feed
    case Sounds
    case Conditions
}

@objc class MainViewController: UITabBarController {
    
    fileprivate static let itemInset = CGFloat(6)
    fileprivate var presenters = Array<HEMPresenter>()
    fileprivate var modalTransition: HEMSimpleModalTransitionDelegate?
    fileprivate let deviceService = HEMDeviceService()
    fileprivate var trendsService: HEMTrendsService!
    fileprivate var alertNetworkService: HEMNetworkAlertService!
    fileprivate var alertDeviceService: HEMDeviceAlertService!
    fileprivate var alertTZService: HEMTimeZoneAlertService!
    fileprivate var alertSystemService: HEMSystemAlertService!
    fileprivate weak var shortcutHandler: ShortcutHandler?
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.listenToAppEvents()
        self.configureTabs()
        self.configureAlertPresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenters.forEach{ $0.willAppear() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenters.forEach{ $0.didAppear() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenters.forEach{ $0.willDisappear() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenters.forEach{ $0.didDisappear() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("tabbar index ", self.view.subviews.index(of: self.tabBar) ?? -1)
        self.presenters.forEach{ $0.didRelayout() }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent != nil {
            self.presenters.forEach{ $0.didMoveToParent() }
        } else {
            self.presenters.forEach{ $0.wasRemovedFromParent() }
        }
    }
    
    // MARK: - App Events
    
    fileprivate func listenToAppEvents() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(viewDidBecomeActive),
                           name: Notification.Name.UIApplicationDidBecomeActive,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(viewDidResignActive),
                           name: Notification.Name.UIApplicationDidEnterBackground,
                           object: nil)
    }
    
    @objc fileprivate func viewDidResignActive() {
        self.presenters.forEach{ $0.didEnterBackground() }
    }
    
    @objc fileprivate func viewDidBecomeActive() {
        self.presenters.forEach{ $0.didComeBackFromBackground() }
    }
    
    // MARK: - Tab Configuration
    
    fileprivate func configureTabs() {
        let timelineVC = HEMSleepSummarySlideViewController()
        let trendsVC = self.trendsController()!
        let feedVC = self.feedController()!
        let soundsVC = self.soundController()!
        let conditionsVC = HEMMainStoryboard.instantiateCurrentNavController() as! UIViewController
        self.viewControllers = [timelineVC, trendsVC, feedVC, soundsVC, conditionsVC];
        
        // hide titles and center tab icons from the controllers
        let topInset = MainViewController.itemInset
        let inset = UIEdgeInsets(top: MainViewController.itemInset, left: 0, bottom: -topInset, right: 0)
        for item in self.tabBar.items! {
            item.imageInsets = inset
            item.title = nil
        }
    }
    
    fileprivate func trendsController() -> UIViewController! {
        self.trendsService = HEMTrendsService()
        
        let weekVC = HEMMainStoryboard.instantiateSleepTrendsViewController() as! HEMTrendsV2ViewController
        let monthVC = HEMMainStoryboard.instantiateSleepTrendsViewController() as! HEMTrendsV2ViewController
        let quarterVC = HEMMainStoryboard.instantiateSleepTrendsViewController() as! HEMTrendsV2ViewController
        
        weekVC.presenter = HEMTrendsGraphsPresenter(trendsService: self.trendsService,
                                                    dataScale: SENTrendsTimeScale.week)
        monthVC.presenter = HEMTrendsGraphsPresenter(trendsService: self.trendsService,
                                                     dataScale: SENTrendsTimeScale.month)
        quarterVC.presenter = HEMTrendsGraphsPresenter(trendsService: self.trendsService,
                                                       dataScale: SENTrendsTimeScale.quarter)
        
        let slidePresenter = SlideContentPresenter(controllers: [weekVC, monthVC, quarterVC])!
        return self.slideContainer(presenter: slidePresenter)
    }
    
    fileprivate func feedController() -> UIViewController! {
        let insightVC = HEMMainStoryboard.instantiateInsightsFeedViewController() as! UIViewController
        let voiceVC = HEMMainStoryboard.instantiateVoiceViewController() as! UIViewController
        let presenter = FeedContentPresenter(controllers: [insightVC, voiceVC],
                                             deviceService: self.deviceService)
        return self.slideContainer(presenter: presenter)
    }
    
    fileprivate func soundController() -> UIViewController! {
        let alarmVC = HEMMainStoryboard.instantiateAlarmListViewController() as! HEMAlarmListViewController
        alarmVC.deviceService = self.deviceService
        
        let sleepSoundVC = HEMMainStoryboard.instantiateSleepSoundViewController() as! HEMSleepSoundViewController
        sleepSoundVC.deviceService = self.deviceService
        
        let presenter = SlideContentPresenter(controllers: [alarmVC, sleepSoundVC])!
        
        return self.slideContainer(presenter: presenter)!
    }
    
    fileprivate func slideContainer(presenter: SlideContentPresenter!) -> UIViewController! {
        let container = HEMMainStoryboard.instantiateSlideContainerViewController() as! SlideContainerViewController
        container.contentPresenter = presenter
        let navVC = HEMStyledNavigationViewController(rootViewController: container)
        navVC.view.backgroundColor = UIColor.white
        return navVC
    }
    
    // MARK: - Tab Switching
    
    @objc func switchTab(tab: MainTab) {
        self.selectedIndex = tab.rawValue
    }
    
    // MARK: - Clean up
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainViewController: HEMSystemAlertDelegate {
    
    fileprivate func configureAlertPresenter() {
        self.alertTZService = HEMTimeZoneAlertService()
        self.alertSystemService = HEMSystemAlertService()
        self.alertDeviceService = HEMDeviceAlertService()
        self.alertNetworkService = HEMNetworkAlertService()
        
        let presenter = HEMSystemAlertPresenter(networkAlertService: self.alertNetworkService,
                                                deviceAlertService: self.alertDeviceService,
                                                timeZoneAlertService: self.alertTZService,
                                                deviceService: self.deviceService,
                                                sysAlertService: self.alertSystemService)
        
        presenter.bind(withContainerView: self.view, below: self.tabBar)
        presenter.delegate = self
        self.presenters.append(presenter)
    }
    
    func present(_ controller: UIViewController, from presenter: HEMSystemAlertPresenter) {
        if controller is HEMTimeZoneViewController {
            self.modalTransition = HEMSimpleModalTransitionDelegate()
            self.modalTransition!.wantsStatusBar = true
            controller.transitioningDelegate = self.modalTransition!
            controller.modalPresentationStyle = UIModalPresentationStyle.custom
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func dismissCurrentViewController(from presenter: HEMSystemAlertPresenter) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentSupportPage(withSlug supportPageSlug: String,
                            from presenter: HEMSystemAlertPresenter) {
        HEMSupportUtil.openHelp(toPage: supportPageSlug, from: self)
    }
    
}

extension MainViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.selectedViewController {
            var mainController = viewController
            if mainController is UINavigationController {
                mainController = (mainController as! UINavigationController).topViewController!
            }
            (mainController as? Scrollable)?.scrollToTop()
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        if (viewController is HEMSleepSummarySlideViewController) {
            // always show last night when switched tapped
            let lastNight = NSDate.timelineInitial()
            let timelineSlideVC = viewController as! HEMSleepSummarySlideViewController
            timelineSlideVC.reload(with: lastNight)
        }
    }
    
}

extension MainViewController: ShortcutHandler {
    
    func canHandleAction(action: HEMShortcutAction) -> Bool {
        guard self.viewControllers != nil else {
            return false
        }
        
        guard self.viewControllers!.count > 0 else {
            return false
        }
        
        var handled = false
        for (index, controller) in self.viewControllers!.enumerated() {
            var contentController = controller
            if contentController is UINavigationController {
                contentController = (contentController as! UINavigationController).topViewController!
            }
            if let handler = contentController as? ShortcutHandler {
                if handler.canHandleAction(action: action) == true {
                    self.switchTab(tab: MainTab(rawValue: index)!)
                    self.shortcutHandler = handler
                    handled = true
                    break
                }
            }
        }
        
        return handled
    }
    
    func takeAction(action: HEMShortcutAction) {
        self.shortcutHandler?.takeAction(action: action)
        self.shortcutHandler = nil
    }
    
}
