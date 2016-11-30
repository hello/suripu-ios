//
//  HEMSleepSummarySlideViewController.h
//  Sense
//
//  Created by Jimmy Lu on 8/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSleepSummarySlideViewController : UIPageViewController

- (instancetype)initWithDate:(NSDate*)date;

- (void)reloadData;

- (void)reloadWithDate:(NSDate*)date;

- (void)reloadDataWithController:(UIViewController*)controller;

- (void)setSwipingEnabled:(BOOL)enabled;

@end
