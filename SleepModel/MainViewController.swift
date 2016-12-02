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

    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.configureTabs()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: - Configuration methods
    
    private func configureTabs() {
        let timelineVC = HEMSleepSummarySlideViewController()
        let trendsVC = HEMMainStoryboard.instantiateTrendsViewController() as! UIViewController
        let feedVC = HEMMainStoryboard.instantiateFeedViewController() as! UIViewController
        let soundsVC = HEMMainStoryboard.instantiateSoundsNavigationViewController() as! UIViewController
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
