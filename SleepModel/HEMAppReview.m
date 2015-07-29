//
//  HEMAppReview.m
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMAppReview.h"
#import "HEMAppUsage.h"
#import "HEMAlertViewController.h"
#import "NSDate+HEMRelative.h"
#import "HEMConfig.h"

@implementation HEMAppReview

NSUInteger const HEMAppPromptReviewThreshold = 60;
NSUInteger const HEMMinimumAppLaunches = 4;
NSUInteger const HEMSystemAlertShownThreshold = 30;
NSUInteger const HEMMinimumTimelineViews = 10;

#pragma mark - Conditions for app review

+ (void)shouldAskUserToRateTheApp:(void(^)(BOOL ask))completion {
    if (!completion) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL meetsInitialRequirements
             = [self hasAppReviewURL]
            && [self isWithinAppReviewThreshold]
            && [self meetsMinimumRequiredAppLaunches]
            && [self meetsMinimumRequiredTimelineViews]
            && [self isWithinSystemAlertThreshold];
        
        if (meetsInitialRequirements) {
            [self hasSenseAndPaired:completion];
        } else {
            completion (NO);
        }
    });
}

/**
 * @discussion
 */
+ (void)hasSenseAndPaired:(void(^)(BOOL hasPairedDevices))completion {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    [deviceService loadDeviceInfo:^(NSError *error) {
        completion (error == nil && [deviceService senseInfo] && [deviceService pillInfo]);
    }];
}

+ (BOOL)hasAppReviewURL {
    NSString* url = [HEMConfig stringForConfig:HEMConfAppReviewURL];
    return url != nil;
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

+ (void)markAppReviewPromptCompleted {
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
}

+ (void)rateApp {
    NSString* url = [HEMConfig stringForConfig:HEMConfAppReviewURL];
    if (url) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
