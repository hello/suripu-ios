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

static CGFloat const HEMTimelineHHDisplayDelay = 1.0f;

@interface HEMTimelineHandHoldingPresenter()

@property (nonatomic, weak) HEMHandHoldingService* service;
@property (nonatomic, weak) UIView* timelineContainerView;
@property (nonatomic, weak) HEMTimelineTopBarCollectionReusableView* topBar;

@end

@implementation HEMTimelineHandHoldingPresenter

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService {
    self = [super init];
    if (self) {
        _service = handHoldingService;
    }
    return self;
}

- (void)bindWithTimelineContainerView:(UIView*)containerView {
    _timelineContainerView = containerView;
}

- (void)bindWithTimelineTopBar:(HEMTimelineTopBarCollectionReusableView*)topBar {
    _topBar = topBar;
}

- (void)showIfNeeded {
    if ([[self delegate] isTimelineFullyVisibleFor:self]) {
        if ([[self service] shouldShow:HEMHandHoldingTimelineOpen]) {
            [self showTimelineOpenTutorial];
        } else if ([[self service] shouldShow:HEMHandHoldingTimelineSwipe]) {
            [self showTimelineSwipeTutorial];
        } else if ([[self service] shouldShow:HEMHandHoldingTimelineZoom]) {
            [self showTimelineZoomTutorial];
        }
    }
}

- (void)delayBlock:(void(^)())block {
    int64_t delta = (int64_t)(HEMTimelineHHDisplayDelay * NSEC_PER_SEC);
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, delta);
    dispatch_after(after, dispatch_get_main_queue(), block);
}

- (void)showTimelineOpenTutorial {
    __weak typeof(self) weakSelf = self;
    [self delayBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIButton* menuButton = [[strongSelf topBar] drawerButton];
        CGRect menuFrame = [menuButton convertRect:[menuButton bounds]
                                            toView:[strongSelf timelineContainerView]];
        CGPoint midPoint = CGPointMake(CGRectGetMidX(menuFrame), CGRectGetMidY(menuFrame));
        
        HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
        [handholdingView setGestureStartCenter:midPoint];
        [handholdingView setGestureEndCenter:midPoint];
        
        [handholdingView setMessage:NSLocalizedString(@"handholding.message.timeline-open", nil)];
        [handholdingView setAnchor:HEMHHDialogAnchorBottom];
        
        [handholdingView showInView:[strongSelf timelineContainerView]];
    }];
}

- (void)showTimelineSwipeTutorial {
    
}

- (void)showTimelineZoomTutorial {
    
}

- (void)didOpenTimeline {
//    [[self service] completed:HEMHandHoldingTimelineOpen];
}

- (void)didSwipeOnTimeline {
    [[self service] completed:HEMHandHoldingTimelineSwipe];
}

- (void)didZoomOutOnTimeline {
    [[self service] completed:HEMHandHoldingTimelineZoom];
}

@end
