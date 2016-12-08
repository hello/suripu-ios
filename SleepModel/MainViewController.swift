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

@objc class MainViewController: UITabBarController , UITabBarControllerDelegate{
    
    static let itemInset = CGFloat(6)
    var deviceService: HEMDeviceService!
    var trendsService: HEMTrendsService!

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
    
    // MARK: - Tab Configuration
    
    fileprivate func configureServices() {
        self.deviceService = HEMDeviceService()
        self.trendsService = HEMTrendsService()
    }
    
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
