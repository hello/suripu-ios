//
//  HEMOnboardingUtils.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAPIAccount.h>

#import <AFNetworking/AFURLResponseSerialization.h>

#import "UIFont+HEMStyle.h"

#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDialogViewController.h"
#import "HEMActivityCoverView.h"
#import "HEMSettingsTableViewController.h"

CGFloat const HEMOnboardingShadowOpacity = 0.8f;

static NSString* const HEMOnboardingSettingCheckpoint = @"sense.checkpoint";
static NSString* const HEMOnboardingSettingSSID = @"sense.ssid";

static NSString* const HEMOnboardingErrorResponseMessage = @"message";

@implementation HEMOnboardingUtils

+ (void)applyCommonDescriptionAttributesTo:(NSMutableAttributedString*)attrText {
    UIFont* font = [UIFont onboardingDescriptionFont];
    UIColor* color = [HelloStyleKit onboardingDescriptionColor];
    
    // avoid overriding any substrings that may already have attributes set
    [attrText enumerateAttributesInRange:NSMakeRange(0, [attrText length])
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                  if ([attrs valueForKey:NSFontAttributeName] == nil) {
                                      [attrText addAttribute:NSFontAttributeName
                                                       value:font
                                                       range:range];
                                  }
                                  
                                  if ([attrs valueForKey:NSForegroundColorAttributeName] == nil) {
                                      [attrText addAttribute:NSForegroundColorAttributeName
                                                       value:color
                                                       range:range];
                                  }
                                  
                              }];
}

+ (NSAttributedString*)boldAttributedText:(NSString*)text {
    return [self boldAttributedText:text withColor:nil];
}

+ (NSAttributedString*)boldAttributedText:(NSString *)text withColor:(UIColor*)color {
    UIFont* font = [UIFont onboardingDescriptionBoldFont];
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [attributes setValue:font forKey:NSFontAttributeName];
    
    if (color != nil) {
        [attributes setValue:color forKey:NSForegroundColorAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Checkpoints

+ (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:checkpoint forKey:HEMOnboardingSettingCheckpoint];
    [defaults synchronize]; // save now in case user kills app or something else
}

+ (HEMOnboardingCheckpoint)onboardingCheckpoint {
    return [[NSUserDefaults standardUserDefaults] integerForKey:HEMOnboardingSettingCheckpoint];
}

+ (void)resetOnboardingCheckpoint {
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointStart];
}

+ (UIViewController*)onboardingControllerForCheckpoint:(HEMOnboardingCheckpoint)checkpoint
                                            authorized:(BOOL)authorized {
    
    UIViewController* onboardingController = nil;
    switch (checkpoint) {
        case HEMOnboardingCheckpointStart: {
            if (!authorized) {
                UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                               bundle:[NSBundle mainBundle]];
                onboardingController = [onboardingStoryboard instantiateInitialViewController];
            }
            break;
        }
        case HEMOnboardingCheckpointAccountCreated: {
            onboardingController = [HEMOnboardingStoryboard instantiateDobViewController];
            break;
        }
        case HEMOnboardingCheckpointAccountDone: {
            onboardingController = [HEMOnboardingStoryboard instantiateSenseSetupViewController];
            break;
        }
        case HEMOnboardingCheckpointSenseDone: {
            onboardingController = [HEMOnboardingStoryboard instantiatePillDescriptionViewController];
            break;
        }
        case HEMOnboardingCheckpointPillDone:
        default: {
            break;
        }
    }
    return onboardingController;
}

#pragma mark - Errors

+ (void)showAlertForHTTPError:(NSError*)error
                    withTitle:(NSString*)errorTitle
                         from:(UIViewController*)controller {
    
    NSString* alertMessage = nil;
    SENAPIAccountError errorType = [SENAPIAccount errorForAPIResponseError:error];
    
    if (errorType == SENAPIAccountErrorUnknown) {
        NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        alertMessage = [self httpErrorMessageForStatusCode:[response statusCode]];
    } else {
        alertMessage = [self accountErrorMessageForType:errorType];
    }
    
    UIView* seeThroughView = [controller parentViewController] ? [[controller parentViewController] view] : [controller view];
    HEMDialogViewController* dialogVC = [[HEMDialogViewController alloc] init];
    [dialogVC setTitle:errorTitle];
    [dialogVC setMessage:alertMessage];
    [dialogVC setViewToShowThrough:seeThroughView];
    
    [dialogVC showFrom:controller onDone:^{
        // don't weak reference this since controller must remain until it has
        // been dismissed
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
}

+ (NSString*)accountErrorMessageForType:(SENAPIAccountError)errorType {
    NSString* message = nil;
    switch (errorType) {
        case SENAPIAccountErrorPasswordTooShort:
            message = NSLocalizedString(@"sign-up.error.password-too-short", nil);
            break;
        case SENAPIAccountErrorPasswordInsecure:
            message = NSLocalizedString(@"sign-up.error.password-insecure", nil);
            break;
        case SENAPIAccountErrorNameTooShort:
            message = NSLocalizedString(@"sign-up.error.name-too-short", nil);
            break;
        case SENAPIAccountErrorNameTooLong:
            message = NSLocalizedString(@"sign-up.error.password-too-long", nil);
            break;
        case SENAPIAccountErrorEmailInvalid:
            message = NSLocalizedString(@"sign-up.error.email-invalid", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

+ (NSString*)httpErrorMessageForStatusCode:(NSInteger)statusCode {
    NSString* message = nil;
    // note that we will not attempt to create a message for every error code
    // that exists, but rather only for those that are commonly encountered.
    // We should never return the localizedDescription here as that provides
    // the user a unfriendly message that only iOS developers can actually understand
    switch (statusCode) {
        case 401:
            message = NSLocalizedString(@"authorization.sign-in.failed.message", nil);
            break;
        case 409:
            message = NSLocalizedString(@"sign-up.error.conflict", nil);
            break;
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"network.error.not-connected", nil);
            break;
        case NSURLErrorNetworkConnectionLost:
            message = NSLocalizedString(@"network.error.connection-lost", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            message = NSLocalizedString(@"network.error.cannot-connect-to-host", nil);
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"network.error.timed-out", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

+ (void)dismissOnboardingFlowFrom:(UIViewController*)controller {
    for (UIViewController* viewController in controller.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[HEMSettingsTableViewController class]]) {
            [controller.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    
    [controller.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

+ (void)finisOnboardinghWithMessageFrom:(UIViewController*)controller {
    [HEMOnboardingCache clearCache];
    
    HEMActivityCoverView* activityView = [[HEMActivityCoverView alloc] init];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBEnd];
    
    void (^activityShownCompletion)(void) = ^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0f*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [activityView updateText:NSLocalizedString(@"onboarding.end-message.sleep", nil)
                         successIcon:[HelloStyleKit moon]
                        hideActivity:YES
                          completion:^(BOOL finished) {
                              dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.0f*NSEC_PER_SEC);
                              dispatch_after(time, dispatch_get_main_queue(), ^{
                                  [self dismissOnboardingFlowFrom:controller];
                              });
                          }];
        });
    };
    
    NSString* doneMessage = NSLocalizedString(@"onboarding.end-message.well-done", nil);
    [activityView showInView:[[controller navigationController] view]
                    withText:doneMessage
                 successMark:YES
                  completion:activityShownCompletion];

}

+ (void)applyShadowToButtonContainer:(UIView*)buttonContainer {
    NSShadow* shadow = [HelloStyleKit onboardingButtonContainerShadow];
    CALayer* layer = [buttonContainer layer];
    [layer setShadowRadius:[shadow shadowBlurRadius]];
    [layer setShadowOffset:[shadow shadowOffset]];
    [layer setShadowColor:[[shadow shadowColor] CGColor]];
    [layer setShadowOpacity:1.0f];
    
}

#pragma mark - SSID

+ (void)saveConfiguredSSID:(NSString*)ssid {
    if ([ssid length] == 0) return;
    
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    [defaults setObject:ssid forKey:HEMOnboardingSettingSSID];
    [defaults synchronize];
}

+ (NSString*)lastConfiguredSSID {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    return [defaults stringForKey:HEMOnboardingSettingSSID];
}

+ (void)removeLastConfiguredSSID {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    [defaults removeObjectForKey:HEMOnboardingSettingSSID];
    [defaults synchronize];
}

@end
