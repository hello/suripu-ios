//
//  HEMInsightViewController.h
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SENInsight;
@class HEMInsightViewController;

@protocol HEMInsightViewControllerDelegate <NSObject>

- (void)didDismissInsightFrom:(HEMInsightViewController*)controller;

@optional
- (UIView*)viewToShowThroughFrom:(HEMInsightViewController*)controller;

@end

@interface HEMInsightViewController : UIViewController

@property (nonatomic, strong) SENInsight* insight;
@property (nonatomic, weak)   id<HEMInsightViewControllerDelegate> delegate;

@end
