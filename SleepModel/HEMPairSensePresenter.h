//
//  HEMPairSensePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMOnboardingService;
@class HEMPairSensePresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMPairSenseActionDelegate <NSObject>

- (void)showHelpWithPage:(NSString*)page fromPresenter:(HEMPairSensePresenter*)presenter;
- (void)didPairWithSenseWithCurrentSSID:(NSString*)ssid fromPresenter:(HEMPairSensePresenter*)presenter;
- (void)didCancelPairingFromPresenter:(HEMPairSensePresenter*)presenter;

@end

@interface HEMPairSensePresenter : HEMPresenter

@property (nonatomic, weak, readonly) HEMOnboardingService* onbService;
@property (nonatomic, weak) id<HEMPairSenseActionDelegate> actionDelegate;
@property (nonatomic, copy) NSSet<NSString*>* deviceIdsToExclude;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - methods subclasses should consider overriding

- (void)bindWithActivityContainerView:(UIView*)activityContainerView;
- (void)bindWithNotGlowingButton:(UIButton*)button;
- (void)bindWithNextButton:(UIButton*)button;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel
  descriptionTopConstraint:(NSLayoutConstraint*)topConstraint;
- (void)bindWithIllustrationView:(nullable UIImageView*)illustrationView
             andHeightConstraint:(NSLayoutConstraint*)heightConstraint;
- (void)help;
- (void)proceed;

@end

NS_ASSUME_NONNULL_END