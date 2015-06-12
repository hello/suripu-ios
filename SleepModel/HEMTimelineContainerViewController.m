//
//  HEMTimelineContainerViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineContainerViewController.h"

@interface HEMTimelineContainerViewController ()
@property (nonatomic, weak) IBOutlet UIButton *alarmButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *alarmButtonTrailing;
@end

@implementation HEMTimelineContainerViewController

static CGFloat const HEMAlarmShortcutDefaultTrailing = 8.f;
static CGFloat const HEMAlarmShortcutHiddenTrailing = -60.f;

- (void)showBorder:(BOOL)isVisible {
}

- (void)showBlurWithHeight:(CGFloat)blurHeight {
}

- (void)showAlarmButton:(BOOL)isVisible {
    CGFloat constant = isVisible ? HEMAlarmShortcutDefaultTrailing : HEMAlarmShortcutHiddenTrailing;
    [self moveAlarmButtonWithOffset:constant];
}

- (void)moveAlarmButtonWithOffset:(CGFloat)constant {
    if (self.alarmButtonTrailing.constant != constant) {
        if (constant > 0)
            self.alarmButton.hidden = NO;
        self.alarmButtonTrailing.constant = constant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2f
            animations:^{ [self.view layoutIfNeeded]; }
            completion:^(BOOL finished) {
              if (constant < 0)
                  self.alarmButton.hidden = YES;
            }];
    }
}

@end
