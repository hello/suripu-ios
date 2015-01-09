//
//  HEMSleepGraphAnimator.h
//  Sense
//
//  Created by Delisa Mason on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENSleepResultSegment;

@interface HEMSleepGraphUtils : NSObject

+ (void)presentTimePickerForDate:(NSDate*)nightOfSleep
                         segment:(SENSleepResultSegment*)segment
                  fromController:(UIViewController*)controller;

@end
