//
//  MainViewController.swift
//  Sense
//
//  Created by Jimmy Lu on 11/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

import UIKit

@objc enum MainTab : Int {
    case Timeline = 0
    case Trends
    case Feed
    case Sounds
    case Conditions
}

@objc class MainViewController: UITabBarController , UITabBarControllerDelegate{
    
    static let itemInset = CGFloat(6)
    var deviceService: HEMDeviceService!

    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.configureServices()
        self.configureTabs()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - Configuration methods
    
    fileprivate func configureServices() {
        self.deviceService = HEMDeviceService()
    }
    
    fileprivate func configureTabs() {
        let timelineVC = HEMSleepSummarySlideViewController()
        let trendsVC = HEMMainStoryboard.instantiateTrendsViewController() as! UIViewController
        let feedVC = HEMMainStoryboard.instantiateFeedViewController() as! UIViewController
        
        let alarmVC = HEMMainStoryboard.instantiateAlarmListViewController() as! HEMAlarmListViewController
        
        let sleepSoundVC = HEMMainStoryboard.instantiateSleepSoundViewController() as! HEMSleepSoundViewController
        let soundsVC = self.wrapInSlideContainer(controllers: [alarmVC, sleepSoundVC])!
        
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
    
    fileprivate func wrapInSlideContainer(controllers: Array<UIViewController>!) -> UIViewController! {
        let container = HEMMainStoryboard.instantiateSlideContainerViewController() as! SlideContainerViewController
        container.contentControllers = controllers
        let navVC = HEMStyledNavigationViewController(rootViewController: container)
        navVC.view.backgroundColor = UIColor.white
        return navVC
    }
    
    // MARK: - Tab Switching
    
    @objc func switchTab(tab: MainTab) {
        self.selectedIndex = tab.rawValue
    }
    
    // MARK: - Tab Bar Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController is HEMSleepSummarySlideViewController) {
            // always show last night when switched tapped
            let lastNight = NSDate.timelineInitial()
            let timelineSlideVC = viewController as! HEMSleepSummarySlideViewController
            timelineSlideVC.reload(with: lastNight)
        }
    }
}
