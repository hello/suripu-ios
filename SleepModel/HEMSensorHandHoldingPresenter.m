//
//  HEMSensorHandHoldingPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorHandHoldingPresenter.h"
#import "HEMHandHoldingService.h"
#import "HEMHandholdingView.h"

@interface HEMSensorHandHoldingPresenter()

@property (nonatomic, weak) HEMHandHoldingService* service;
@property (nonatomic, weak) HEMHandholdingView* currentHandHoldingView;

@end

@implementation HEMSensorHandHoldingPresenter

- (instancetype)initWithService:(HEMHandHoldingService*)service {
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (void)showIfNeededIn:(UIView*)view withGraphView:(UIView*)graphView {
    if (!view
        || !graphView
        || ![[self service] shouldShow:HEMHandHoldingSensorScrubbing]
        || [self currentHandHoldingView]) {
        return;
    }
    
    CGRect graphFrame = [graphView convertRect:[graphView bounds] toView:view];
    CGFloat gesturePadding = 20.0f;
    CGFloat halfGestureSize = HEMHandholdingGestureSize / 2.0f;
    CGFloat gestureCenterY = CGRectGetMinY(graphFrame) + gesturePadding + halfGestureSize;
    CGFloat gestureEndCenterX = CGRectGetMaxX(graphFrame) - gesturePadding - halfGestureSize;
    CGPoint startPoint = CGPointMake(gesturePadding + halfGestureSize, gestureCenterY);
    CGPoint endPoint = CGPointMake(gestureEndCenterX, gestureCenterY);
    
    HEMHandholdingView* handholdingView = [[HEMHandholdingView alloc] init];
    [handholdingView setGestureStartCenter:startPoint];
    [handholdingView setGestureEndCenter:endPoint];
    
    [handholdingView setMessage:NSLocalizedString(@"handholding.message.sensor-scrubbing", nil)];
    [handholdingView setAnchor:HEMHHDialogAnchorTop];
    
    __weak typeof(self) weakSelf = self;
    [handholdingView showInView:view fromContentView:graphView dismissAction:^(BOOL shown) {
        __strong typeof(weakSelf) strongSelf = self;
        if (shown) {
            [strongSelf didCompleteSrubbingHandHolding];
        }
    }];
    [self setCurrentHandHoldingView:handholdingView];
}

- (void)didCompleteSrubbingHandHolding {
    [[self service] completed:HEMHandHoldingSensorScrubbing];
}

@end
