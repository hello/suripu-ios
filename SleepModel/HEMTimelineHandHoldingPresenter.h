//
//  HEMTimelineHandHoldingPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 1/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMHandHoldingService;
@class HEMTimelineHandHoldingPresenter;
@class HEMTimelineTopBarCollectionReusableView;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMTimelineHandHoldingDelegate <NSObject>

- (BOOL)isTimelineFullyVisibleFor:(HEMTimelineHandHoldingPresenter*)presenter;

@end

@interface HEMTimelineHandHoldingPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMTimelineHandHoldingDelegate> delegate;

- (instancetype)initWithHandHoldingService:(HEMHandHoldingService*)handHoldingService;
- (void)bindWithTimelineContainerView:(UIView*)containerView;
- (void)bindWithTimelineTopBar:(HEMTimelineTopBarCollectionReusableView*)topBar;
- (void)showIfNeeded;
- (void)didOpenTimeline;
- (void)didSwipeOnTimeline;
- (void)didZoomOutOnTimeline;

@end

NS_ASSUME_NONNULL_END