//
//  HEMLocationRequestPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 6/7/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMLocationService;
@class HEMOnboardingService;
@class HEMActionButton;
@class HEMLocationRequestPresenter;

@protocol HEMLocationRequestPresenterDelegate <NSObject>

- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
                      from:(HEMLocationRequestPresenter*)presenter;

- (void)proceedFrom:(HEMLocationRequestPresenter*)presenter;

@end

@interface HEMLocationRequestPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMLocationRequestPresenterDelegate> delegate;

- (instancetype)initWithLocationService:(HEMLocationService*)locService
                   andOnboardingService:(HEMOnboardingService*)onboardingService;

- (void)bindWithLocationButton:(HEMActionButton*)locationButton;
- (void)bindWithSkipButton:(UIButton*)skipButton;

@end
