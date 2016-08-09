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

typedef void(^HEMSenseDFUActionCallback)(void);

@protocol HEMSenseDFUDelegate <NSObject>

- (void)senseUpdateCompletedFrom:(HEMSenseDFUPresenter*)presenter;
- (void)senseUpdateLaterFrom:(HEMSenseDFUPresenter*)presenter;
- (void)showConfirmationWithTitle:(NSString*)title
                          message:(NSString*)message
                         okAction:(HEMSenseDFUActionCallback)okAction
                     cancelAction:(HEMSenseDFUActionCallback)cancelAction
                             from:(HEMSenseDFUPresenter*)presenter;
- (UIView*)parentContentViewFor:(HEMSenseDFUPresenter*)presenter;

@end

@interface HEMSenseDFUPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMSenseDFUDelegate> dfuDelegate;

- (instancetype)initWithOnboardingService:(HEMOnboardingService*)onbService;
- (void)bindWithUpdateButton:(UIButton*)updateButton;
- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicator
                      statusLabel:(UILabel*)statusLabel;
- (void)bindWithLaterButton:(UIButton*)laterButton;

@end

NS_ASSUME_NONNULL_END