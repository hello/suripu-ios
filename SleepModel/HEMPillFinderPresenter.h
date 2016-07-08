//
//  HEMPillFinderPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMDeviceService;
@class HEMActivityIndicatorView;
@class HEMEmbeddedVideoView;
@class HEMPillFinderPresenter;
@class SENSleepPill;

@protocol HEMPillFinderDelegate <NSObject>

- (void)didFindSleepPill:(SENSleepPill*)pill from:(HEMPillFinderPresenter*)presenter;

@end

@interface HEMPillFinderPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMPillFinderDelegate> finderDelegate;

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService;
- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithStatusLabel:(UILabel*)statusLabel andIndicator:(HEMActivityIndicatorView*)indicatorView;
- (void)bindWithVideoView:(HEMEmbeddedVideoView*)videoView;

@end
