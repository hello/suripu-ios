//
//  HEMUpgradePillDescriptionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENPairedDevices.h>

#import "HEMUpgradePillDescriptionPresenter.h"
#import "HEMAlertViewController.h"
#import "HEMActivityCoverView.h"

@interface HEMUpgradePillDescriptionPresenter()

// need to use a strong reference as the presenter will be created outside of
// a view controller
@property (nonatomic, strong) SENServiceDevice* deviceService;
@property (nonatomic, strong) HEMActivityCoverView* activityView;

@end

@implementation HEMUpgradePillDescriptionPresenter

- (instancetype)initWithDeviceService:(SENServiceDevice*)deviceService {
    self = [super init];
    if (self) {
        _deviceService = deviceService;
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setText:NSLocalizedString(@"upgrade.pill.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.pill.description", nil)];
}

- (void)bindWithContinueButton:(UIButton*)continueButton {
    [super bindWithContinueButton:continueButton];
    [continueButton setTitle:[NSLocalizedString(@"upgrade.actions.pair-pill", nil) uppercaseString]
                    forState:UIControlStateNormal];
}

- (void)bindWithLaterButton:(UIButton*)laterButton {
    [super bindWithLaterButton:laterButton];
    [laterButton setHidden:NO];
    [laterButton setUserInteractionEnabled:YES];
    [laterButton addTarget:self
                    action:@selector(skipPillPairing)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"helpIconSmall"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(moreInfo)];
    [navItem setRightBarButtonItem:item];
}

- (void)skipPillPairing {
    NSString* title = NSLocalizedString(@"upgrade.pill.skip-new-alert.title", nil);
    NSString* message = NSLocalizedString(@"upgrade.pill.skip-new-alert.message", nil);
    __weak typeof(self) weakSelf = self;
    HEMAlertViewController *dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"upgrade.actions.pair-pill", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:^{
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               [[strongSelf delegate] skip:NO fromPresenter:nil];
                          }];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"upgrade.actions.skip-new", nil)
                           style:HEMAlertViewButtonStyleBlueText
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              [[strongSelf delegate] skip:YES fromPresenter:nil];
                          }];
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
    
}

- (void)showErrorMessage:(NSString*)message {
    __weak typeof(self) weakSelf = self;
    void(^show)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* title = NSLocalizedString(@"upgrade.pill.unpair.error.title", nil);
        [[strongSelf errorDelegate] showErrorWithTitle:title
                                            andMessage:message
                                          withHelpPage:nil
                                         fromPresenter:strongSelf];
    };
    
    if ([self activityView]) {
        [[self activityView] dismissWithResultText:nil
                                   showSuccessMark:NO
                                            remove:YES
                                        completion:show];
    } else {
        show();
    }
}

/**
 * @discussion
 * Overriding super class to replace / unpair sleep pill from account
 */
- (void)proceed {
    [self setActivityView:[HEMActivityCoverView new]];
    
    __weak typeof(self) weakSelf = self;
    void(^unpair)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[strongSelf deviceService] unpairSleepPill:^(NSError *error) {
            if (error) {
                [SENAnalytics trackError:error];
                NSString* message = NSLocalizedString(@"upgrade.pill.unpair.error.message", nil);
                [strongSelf showErrorMessage:message];
            } else {
                NSString* successText = NSLocalizedString(@"upgrade.pill.unpair.done", nil);
                // proceed while activity is being dismissed
                [[strongSelf activityView] dismissWithResultText:successText showSuccessMark:YES remove:YES completion:nil];
                [[strongSelf delegate] skip:NO fromPresenter:strongSelf];
            }
        }];
    };
    
    NSString* unpairStatusText = NSLocalizedString(@"upgrade.pill.unpair.status", nil);
    
    if (![[self deviceService] devices]) {
        NSString* statusText = NSLocalizedString(@"upgrade.pill.checking-pill", nil);
        [[self activityView] showInView:[self activityContainerView] withText:statusText activity:YES completion:^{
            [[self deviceService] loadDeviceInfo:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (error) {
                    NSString* message = NSLocalizedString(@"upgrade.pill.checking-pill.error.message", nil);
                    [strongSelf showErrorMessage:message];
                } else {
                    [[strongSelf activityView] updateText:unpairStatusText completion:^(BOOL finished) {
                        unpair();
                    }];
                }
            }];
        }];
    } else if ([[[self deviceService] devices] hasPairedPill]){
        [[self activityView] showInView:[self activityContainerView]
                               withText:unpairStatusText
                               activity:YES
                             completion:unpair];
    } else {
        [[self delegate] skip:NO fromPresenter:self];
    }
}

- (void)moreInfo {
    NSString* page = NSLocalizedString(@"help.url.slug.new-pill-info", nil);
    [[self delegate] showHelpPage:page fromPresenter:self];
}

@end
