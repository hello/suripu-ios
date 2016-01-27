//
//  HEMTimelineHandHoldingPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTimelineHandHoldingPresenter.h"
#import "HEMTimelineTopBarCollectionReusableView.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"

static NSUInteger const HEMTimelineHandHoldingViewTag = 88;

@interface HEMTimelineHandHoldingPresenter()

@property (nonatomic, weak) HEMHandHoldingService* service;

@end

@implementation HEMTimelineHandHoldingPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService {
    self = [super init];
    if (self) {
        _service = handHoldingService;
    }
    return self;
}

- (void)showIfNeeded {
    if ([self canShowTutorial]) {
        if ([[self service] shouldShow:HEMHandHoldingTimelineOpen]) {
            [self showTimelineOpenTutorial];
        } else if ([[self service] shouldShow:HEMHandHoldingTimelineSwipe]) {
            [self showTimelineSwipeTutorial];
        } else if ([[self service] shouldShow:HEMHandHoldingTimelineZoom]) {
            [self showTimelineZoomTutorial];
        }
    }
}

- (BOOL)canShowTutorial {
    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
    UIView* existingView = [containerView viewWithTag:HEMTimelineHandHoldingViewTag];
    return [[self delegate] isTimelineFullyVisibleFor:self] && !existingView;
}

- (void)showTimelineOpenTutorial {
    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
    UIButton* menuButton = [[[self delegate] timelineTopBarForPresenter:self] drawerButton];
    UIImage* icon = [menuButton imageForState:UIControlStateNormal];
    CGRect menuFrame = [menuButton convertRect:[menuButton bounds] toView:containerView];
    
    if (!CGRectIsEmpty(menuFrame)) {
        CGFloat targetX = CGRectGetMinX(menuFrame) + icon.size.width;
        CGFloat targetY = CGRectGetMidY(menuFrame);
        CGPoint midPoint = CGPointMake(targetX, targetY);
        
        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
        
        [handholdingView setGestureStartCenter:midPoint];
        [handholdingView setGestureEndCenter:midPoint];
        
        [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-open", nil)];
        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
        
        [handholdingView showInView:containerView];
        [handholdingView setTag:HEMTimelineHandHoldingViewTag];
    }
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
    
    [handholdingView showInView:containerView];
}

- (void)showTimelineZoomTutorial {
    UIView* containerView = [[self delegate] timelineContainerViewForPresenter:self];
    UIButton* dateButton = [[[self delegate] timelineTopBarForPresenter:self] dateButton];
    CGRect dateFrame = [dateButton convertRect:[dateButton bounds] toView:containerView];
    
    if (!CGRectIsEmpty(dateFrame)) {
        CGPoint midPoint = CGPointMake(CGRectGetMidX(dateFrame), CGRectGetMidY(dateFrame));
        
        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
        
        [handholdingView setGestureStartCenter:midPoint];
        [handholdingView setGestureEndCenter:midPoint];
        
        [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-zoom", nil)];
        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
        [handholdingView setTag:HEMTimelineHandHoldingViewTag];
        
        [handholdingView showInView:containerView];
    }
}

- (void)didOpenTimeline {
    [[self service] completed:HEMHandHoldingTimelineOpen];
}

- (void)didZoomOutOnTimeline {
    [[self service] completed:HEMHandHoldingTimelineZoom];
}

// did swipe method is not done through the Timeline itself, but from the slide
// controller, which simply goes directly to the service to mark it as completed

@end
