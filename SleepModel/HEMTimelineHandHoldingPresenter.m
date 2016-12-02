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

@end

@implementation HEMTimelineHandHoldingPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService {
    self = [super init];
    if (self) {
        _service = handHoldingService;
    }
    return self;
}

- (void)bindWithContentView:(UIView*)contentView {
    [self setContentView:contentView];
}

- (void)showIfNeeded {
    if ([self canShowTutorial]) {
        if ([[self service] shouldShow:HEMHandHoldingTimelineSwipe]) {
            [self showTimelineSwipeTutorial];
        } else if ([[self service] shouldShow:HEMHandHoldingTimelineZoom]) {
            [self showTimelineZoomTutorial];
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

- (void)showTimelineZoomTutorial {
#pragma message ("add this back in!")
//    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
//    UIButton* dateButton = [[[self delegate] timelineTopBarForPresenter:self] dateButton];
//    CGRect dateFrame = [dateButton convertRect:[dateButton bounds] toView:containerView];
//    
//    if (!CGRectIsEmpty(dateFrame)) {
//        CGPoint midPoint = CGPointMake(CGRectGetMidX(dateFrame), CGRectGetMidY(dateFrame));
//        
//        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
//        
//        [handholdingView setGestureStartCenter:midPoint];
//        [handholdingView setGestureEndCenter:midPoint];
//        
//        [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-zoom", nil)];
//        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
//        [handholdingView setTag:HEMTimelineHandHoldingViewTag];
//        
//        __weak typeof(self) weakSelf = self;
//        [handholdingView showInView:containerView fromContentView:[self contentView] dismissAction:^(BOOL shown) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            if (shown) {
//                [strongSelf didZoomOutOnTimeline];
//            }
//        }];
//    }
}

- (void)didZoomOutOnTimeline {
    [[self service] completed:HEMHandHoldingTimelineZoom];
}

// did swipe method is not done through the Timeline itself, but from the slide
// controller, which simply goes directly to the service to mark it as completed

@end
