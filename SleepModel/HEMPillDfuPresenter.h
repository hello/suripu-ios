//
//  HEMPillDfuPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMDeviceService;
@class HEMPillDfuPresenter;
@class SENSleepPill;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMPillDfuDelegate <NSObject>

- (void)bleRequiredToProceedFrom:(HEMPillDfuPresenter*)presenter;
- (void)shouldStartScanningForPillFrom:(HEMPillDfuPresenter*)presenter;
- (UIView*)viewToAttachToWhenFinishedIn:(HEMPillDfuPresenter*)presenter;
- (void)didCompleteDfuFrom:(HEMPillDfuPresenter*)presenter;
- (void)didCancelDfuFrom:(HEMPillDfuPresenter*)presenter;
- (void)showHelpWithSlug:(NSString*)slug fromPresenter:(HEMPillDfuPresenter*)presenter;

@end

@interface HEMPillDfuPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMPillDfuDelegate> dfuDelegate;
@property (nonatomic, strong) SENSleepPill* pillToDfu;

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService;
- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithActionButton:(UIButton*)actionButton;
- (void)bindWithProgressView:(UIProgressView*)progressView statusLabel:(UILabel*)statusLabel;
- (void)bindWithCancelButton:(UIButton*)cancelButton;
- (void)bindWithHelpButton:(UIButton*)helpButton;

@end

NS_ASSUME_NONNULL_END