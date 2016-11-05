//
//  HEMPairSensePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"
#import <SenseKit/SENSense.h>

@class HEMOnboardingService;
@class HEMDeviceService;
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
@property (nonatomic, assign) SENSenseAdvertisedVersion versionOfSenseToFind; // unknown will return nearest
@property (nonatomic, assign, getter=isUpgrading) BOOL upgrade;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService
                            deviceService:(HEMDeviceService*)deviceService NS_DESIGNATED_INITIALIZER;
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
- (void)trackEvent:(NSString*)event properties:(NSDictionary*)props;
- (void)help;
- (void)proceed;

@end

NS_ASSUME_NONNULL_END