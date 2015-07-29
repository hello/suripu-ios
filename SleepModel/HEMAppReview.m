//
//  HEMAppReview.m
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import "HEMAppReview.h"
#import "HEMAppUsage.h"
#import "HEMAlertViewController.h"
#import "NSDate+HEMRelative.h"

@implementation HEMAppReview

NSUInteger const HEMAppPromptReviewThreshold = 60;
NSUInteger const HEMMinimumAppLaunches = 4;
NSUInteger const HEMSystemAlertShownThreshold = 30;
NSUInteger const HEMMinimumTimelineViews = 10;

NSString *const HEMReviewPrompted = @"HEMReviewPrompted";

#pragma mark - Conditions for app review

+ (BOOL)shouldAskUserToRateTheApp {
    return [self isWithinAppReviewThreshold]
        && [self meetsMinimumRequiredAppLaunches]
        && [self meetsMinimumRequiredTimelineViews]
        && [self isWithinSystemAlertThreshold];
}

+ (BOOL)isWithinAppReviewThreshold {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
    NSDate* lastUpdated = [appUsage updated];
    return !lastUpdated || [lastUpdated daysElapsed] > HEMAppPromptReviewThreshold;
}

+ (BOOL)meetsMinimumRequiredTimelineViews {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
    NSUInteger viewsIn31Days = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
    return viewsIn31Days >= HEMMinimumTimelineViews;
}

+ (BOOL)meetsMinimumRequiredAppLaunches {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppLaunched];
    NSUInteger appLaunches = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
    return appLaunches >= HEMMinimumAppLaunches;
}

+ (BOOL)isWithinSystemAlertThreshold {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageSystemAlertShown];
    NSDate* lastUpdated = [appUsage updated];
    return !lastUpdated || [lastUpdated daysElapsed] > HEMSystemAlertShownThreshold;
}

#pragma mark -

+ (void)askToRateAppFrom:(UIViewController *)controller {
    [self setDidAskToRateApp];
    [HEMAlertViewController
        showBooleanChoiceDialogWithTitle:NSLocalizedString(@"review.like-app.title", nil)
                                 message:NSLocalizedString(@"review.like-app.message", nil)
                              controller:controller
                                  action:^{
                                    [controller dismissViewControllerAnimated:YES
                                                                   completion:^{
                                                                     [self presentAppRatingDialogFrom:controller];
                                                                   }];
                                  }];
}

+ (BOOL)didAskToRateApp {
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
    return [[[SENLocalPreferences sharedPreferences] userPreferenceForKey:HEMReviewPrompted] boolValue];
}

+ (void)rateApp {
    NSString *const HEMReviewURI = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/"
        @"viewContentsUserReviews?id=942698761&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:HEMReviewURI]];
}

+ (void)presentAppRatingDialogFrom:(UIViewController *)controller {
    [HEMAlertViewController showBooleanChoiceDialogWithTitle:NSLocalizedString(@"review.rate-app.title", nil)
                                                     message:NSLocalizedString(@"review.rate-app.message", nil)
                                                  controller:controller
                                                      action:^{
                                                        [controller dismissViewControllerAnimated:YES completion:NULL];
                                                        [self rateApp];
                                                      }];
}

+ (void)setDidAskToRateApp {
    SENLocalPreferences *preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:@(YES) forKey:HEMReviewPrompted];
}
@end
