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
#import "HEMMainStoryboard.h"
#import "NSDate+HEMRelative.h"
#import "HEMShortcutService.h"

@interface HEMTimelineContainerViewController ()
@property (nonatomic, weak) IBOutlet UIButton *alarmButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alarmButtonTrailing;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@end

@implementation HEMTimelineContainerViewController

CGFloat const HEMAlarmShortcutDefaultTrailing = -16.f;
CGFloat const HEMAlarmShortcutHiddenTrailing = 60.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayTimelineController];
}

- (void)displayTimelineController {
    if (self.timelineController) {
        [self.timelineController willMoveToParentViewController:nil];
        [self.timelineController removeFromParentViewController];
        [self addChildViewController:self.timelineController];
        [self.view insertSubview:self.timelineController.view atIndex:0];
        [self.timelineController didMoveToParentViewController:self];
    }
}

#pragma mark - Alarm

- (IBAction)alarmButtonTapped:(id)sender {
    [[HEMShortcutService sharedService] notifyOfAction:HEMShortcutActionAlarmEdit];
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

@end
