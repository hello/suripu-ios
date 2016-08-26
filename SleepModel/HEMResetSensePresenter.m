//
//  HEMResetSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIBarButtonItem+HEMNav.h"

#import "HEMResetSensePresenter.h"
#import "HEMActivityCoverView.h"
#import "HEMStyle.h"
#import "HEMDeviceService.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMResetSenseFinishDelay = 2.0f;

@interface HEMResetSensePresenter()

@property (nonatomic, weak) UIView* activityContainerView;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, copy) NSString* senseId;
@property (nonatomic, weak) UIButton* laterButton;

@end

@implementation HEMResetSensePresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService
                              senseId:(NSString *)senseId {
    self = [super init];
    if (self) {
        _deviceService = deviceService;
        _senseId = [senseId copy];
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"upgrade.reset.sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.reset.sense.description", nil)];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [laterButton setHidden:YES];
    [laterButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[laterButton titleLabel] setFont:[UIFont button]];
    [laterButton addTarget:self
                    action:@selector(later)
          forControlEvents:UIControlEventTouchUpInside];
    [self setLaterButton:laterButton];
}

- (void)bindWithResetButton:(UIButton*)resetButton {
    [resetButton addTarget:self
                    action:@selector(reset)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithActivityContainerView:(UIView*)containerView {
    [self setActivityContainerView:containerView];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    UIBarButtonItem* helpButton = [UIBarButtonItem helpButtonWithTarget:self action:@selector(help)];
    [navItem setRightBarButtonItem:helpButton];
}

#pragma mark - Actions

- (void)reset {
    if (![self deviceService] || ![self senseId]) {
        return [self later];
    }
    
    NSString* activityMessage = NSLocalizedString(@"settings.device.restoring-factory-settings", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainerView] withText:activityMessage activity:YES completion:^{
        __weak typeof(self) weakSelf = self;
        [[self deviceService] hardFactoryResetSense:[self senseId] completion:^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                [[strongSelf laterButton] setHidden:NO];
                [activityView dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
                    NSString* message = NSLocalizedString(@"upgrade.reset.error.message", nil);
                    NSString* title = NSLocalizedString(@"upgrade.reset.error.title", nil);
                    [[strongSelf errorDelegate] showErrorWithTitle:title
                                                        andMessage:message
                                                      withHelpPage:nil
                                                     fromPresenter:strongSelf];
                }];
            } else {
                NSString* message = NSLocalizedString(@"status.success", nil);
                UIImage* check = [UIImage imageNamed:@"check"];
                [[activityView indicator] setHidden:YES];
                [activityView updateText:message successIcon:check hideActivity:YES completion:^(BOOL finished) {
                    [activityView showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                        [self delayFinish:YES];
                    }];
                }];
            }
        }];
    }];
}

- (void)later {
    NSString* message = NSLocalizedString(@"status.success", nil);
    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[self activityContainerView] withText:message successMark:YES completion:^{
        [self delayFinish:NO];
    }];
}

- (void)help {
    NSString* step = kHEMAnalyticsEventPropResetSense;
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventOnBHelp properties:properties];
    
    NSString* page = NSLocalizedString(@"help.url.slug.factory-reset", nil);
    [[self delegate] showHelpWithPage:page fromPresenter:self];
}

- (void)delayFinish:(BOOL)reset {
    int64_t delayInSecs = (int64_t) (HEMResetSenseFinishDelay * NSEC_PER_SEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSecs), dispatch_get_main_queue(), ^{
        [[self delegate] didFinishWithReset:reset fromPresenter:self];
    });
}

@end
