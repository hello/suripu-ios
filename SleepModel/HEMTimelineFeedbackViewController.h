//
//  HEMTimelineFeedbackViewController.h
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const HEMTimelineFeedbackSuccessNotification;

@class SENTimelineSegment;

@interface HEMTimelineFeedbackViewController : UIViewController

@property (nonatomic, strong) SENTimelineSegment* segment;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
