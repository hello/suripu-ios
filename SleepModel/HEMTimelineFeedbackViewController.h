//
//  HEMTimelineFeedbackViewController.h
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const HEMMTimelineFeedbackSuccessNotification;
extern NSString* const HEMMTimelineFeedbackFailureNotification;

@class SENSleepResultSegment;

@interface HEMTimelineFeedbackViewController : UIViewController

+ (BOOL)canAdjustTimeForSegment:(SENSleepResultSegment*)segment;

@property (nonatomic, strong) SENSleepResultSegment* segment;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
