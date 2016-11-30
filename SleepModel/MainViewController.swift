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

@objc class MainViewController: UITabBarController {

    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTabs()
    }
    
    // MARK: - Configuration methods
    
    private func configureTabs() {
        let timelineVC = HEMSleepSummarySlideViewController()
        let trendsVC = HEMMainStoryboard.instantiateTrendsViewController() as! UIViewController
        let feedVC = HEMMainStoryboard.instantiateFeedViewController() as! UIViewController
        let soundsVC = HEMMainStoryboard.instantiateSoundsNavigationViewController() as! UIViewController
        let conditionsVC = HEMMainStoryboard.instantiateCurrentNavController() as! UIViewController
        self.viewControllers = [timelineVC, trendsVC, feedVC, soundsVC, conditionsVC];
    }
    
    // MARK: Tab Switching
    
    @objc func switchTab(tab: MainTab) {
        self.selectedIndex = tab.rawValue
    }
}
