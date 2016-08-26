//
//  HEMResetSensePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMResetSensePresenter;
@class HEMDeviceService;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMResetPresenterDelegate <NSObject>

- (void)didFinishWithReset:(BOOL)reset fromPresenter:(HEMResetSensePresenter*)presenter;
- (void)showHelpWithPage:(NSString*)page fromPresenter:(HEMResetSensePresenter*)presenter;

@end

@interface HEMResetSensePresenter : HEMPresenter

@property (nonatomic, weak) id<HEMResetPresenterDelegate> delegate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDeviceService:(nullable HEMDeviceService*)deviceService
                              senseId:(nullable NSString*)senseId NS_DESIGNATED_INITIALIZER;
- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithLaterButton:(UIButton*)laterButton;
- (void)bindWithResetButton:(UIButton*)resetButton;
- (void)bindWithActivityContainerView:(UIView*)containerView;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;

@end

NS_ASSUME_NONNULL_END