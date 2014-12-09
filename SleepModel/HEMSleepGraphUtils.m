//
//  HEMSleepGraphAnimator.m
//  Sense
//
//  Created by Delisa Mason on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPIFeedback.h>
#import "HEMSleepGraphUtils.h"
#import "HEMAlertController.h"

@implementation HEMSleepGraphUtils

+ (void)presentTimePickerForDate:(NSDate*)nightOfSleep segment:(SENSleepResultSegment*)segment fromController:(UIViewController*)controller
{
    void (^completion)(NSDate*) = ^(NSDate *date) {
        if (!date)
            return;

        [SENAPIFeedback sendAccurateWakeupTime:date
                            detectedWakeupTime:segment.date
                               forNightOfSleep:nightOfSleep
                                    completion:NULL];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"sleep-event.verify-complete.title", nil)
                                                  message:NSLocalizedString(@"sleep-event.verify-complete.message", nil)
                                     presentingController:controller];
        });
    };
    [HEMAlertController presentDatePickerAlertWithTitle:NSLocalizedString(@"sleep-event.verify.title", nil)
                                                message:NSLocalizedString(@"sleep-event.verify.message", nil)
                                   presentingController:controller
                                         datePickerMode:UIDatePickerModeTime
                                            initialDate:segment.date
                                             completion:completion];
}

@end
