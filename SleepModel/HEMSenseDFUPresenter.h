//
//  HEMSenseDFUPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import "HEMOnboardingService.h"

@class HEMActivityIndicatorView;
@class HEMSenseDFUPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMSenseDFUDelegate <NSObject>

- (void)senseUpdateCompletedFrom:(HEMSenseDFUPresenter*)presenter;
- (void)senseUpdateLaterFrom:(HEMSenseDFUPresenter*)presenter;

@end

@interface HEMSenseDFUPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSenseDFUDelegate> dfuDelegate;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService;
- (void)bindWithUpdateButton:(UIButton*)updateButton;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicator
                      statusLabel:(UILabel*)statusLabel;

@end

NS_ASSUME_NONNULL_END