//
//  HEMTimelineContainerViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <SenseKit/SENTimeline.h>
#import "HEMTimelineContainerViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "HEMRootViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "NSDate+HEMRelative.h"

@interface HEMTimelineContainerViewController ()
@property (nonatomic, weak) IBOutlet UIButton *alarmButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alarmButtonTrailing;
@end

@implementation HEMTimelineContainerViewController

CGFloat const HEMAlarmShortcutDefaultTrailing = -16.f;
CGFloat const HEMAlarmShortcutHiddenTrailing = 60.f;


- (IBAction)alarmButtonTapped:(id)sender {
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabAlarms animated:YES];
}

- (void)showAlarmButton:(BOOL)isVisible {
    CGFloat constant = isVisible ? HEMAlarmShortcutDefaultTrailing : HEMAlarmShortcutHiddenTrailing;
    [self moveAlarmButtonWithOffset:constant];
}

- (void)moveAlarmButtonWithOffset:(CGFloat)constant {
    if (self.alarmButtonTrailing.constant != constant) {
        self.alarmButtonTrailing.constant = constant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3f
            delay:0
            usingSpringWithDamping:0.8
            initialSpringVelocity:0
            options:UIViewAnimationOptionBeginFromCurrentState
            animations:^{
              [self.alarmButton layoutIfNeeded];
            }
            completion:NULL];
    }
}

#pragma mark Top bar actions



@end
