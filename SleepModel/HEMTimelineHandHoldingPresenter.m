//
//  HEMTimelineHandHoldingPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTimelineHandHoldingPresenter.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"

static NSUInteger const HEMTimelineHandHoldingViewTag = 88;

@interface HEMTimelineHandHoldingPresenter()

@property (nonatomic, weak) HEMHandHoldingService* service;
@property (nonatomic, weak) UIView* contentView;
@property (nonatomic, assign) CGFloat bottomOffset;

@end

@implementation HEMTimelineHandHoldingPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService {
    self = [super init];
    if (self) {
        _service = handHoldingService;
    }
    return self;
}

- (void)bindWithContentView:(UIView*)contentView bottomOffset:(CGFloat)bottomOffset {
    [self setContentView:contentView];
    [self setBottomOffset:bottomOffset];
}

- (void)showIfNeeded {
    if ([self canShowTutorial]) {
        if ([[self service] shouldShow:HEMHandHoldingTimelineSwipe]) {
            [self showTimelineSwipeTutorial];
        }
    }
}

- (BOOL)canShowTutorial {
    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
    UIView* existingView = [containerView viewWithTag:HEMTimelineHandHoldingViewTag];
    return !existingView;
}

- (void)showTimelineSwipeTutorial {
    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
    CGFloat const SWIPE_Y = 205.0f;
    CGFloat const SWIPE_X = 45.0f;
    CGFloat widthConstraint = CGRectGetWidth([containerView bounds]);
    
    HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
    
    [handholdingView setGestureStartCenter:CGPointMake(SWIPE_X, SWIPE_Y)];
    [handholdingView setGestureEndCenter:CGPointMake(widthConstraint - SWIPE_X, SWIPE_Y)];
    [handholdingView setMessageYOffset:[self bottomOffset]];
    [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-switch-days", nil)];
    [handholdingView setAnchor:HEMHHDialogAnchorBottom];
    [handholdingView setTag:HEMTimelineHandHoldingViewTag];
    
    __weak typeof(self) weakSelf = self;
    [handholdingView showInView:containerView fromContentView:[self contentView] dismissAction:^(BOOL shown) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (shown) {
            [[strongSelf service] completed:HEMHandHoldingTimelineSwipe];
        }
    }];
}

@end
