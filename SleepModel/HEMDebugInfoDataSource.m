//
//  HEMDebugInfoDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 8/25/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/API.h>

#import "NSDate+HEMRelative.h"

#import "HEMDebugInfoDataSource.h"
#import "HEMConfig.h"
#import "HEMAppUsage.h"
#import "HEMAppReview.h"
#import "HEMHealthKitService.h"

typedef NS_ENUM(NSUInteger, HEMDebugInfoSection) {
    HEMDebugInfoSectionApp = 0,
    HEMDebugInfoSectionConfig = 1,
    HEMDebugInfoSectionUsage = 2,
    HEMDebugInfoSections = 3
};

typedef NS_ENUM(NSUInteger, HEMDebugInfoAppRow) {
    HEMDebugInfoAppRowVersion = 0,
    HEMDebugInfoAppRowAccountId = 1,
    HEMDebugInfoAppRows = 2
};

typedef NS_ENUM(NSUInteger, HEMDebugInfoConfig) {
    HEMDebugInfoConfigApiURL = 0,
    HEMDebugInfoConfigClientId = 1,
    HEMDebugInfoConfigZendeskClientId = 2,
    HEMDebugInfoConfigZendeskToken = 3,
    HEMDebugInfoConfigMixpanelToken = 4,
    HEMDebugInfoConfigAppReviewURL = 5,
    HEMDebugInfoConfigForgotPwURL = 6,
    HEMDebugInfoConfigRows = 7
};

typedef NS_ENUM(NSUInteger, HEMDebugInfoUsage) {
    HEMDebugInfoUsageHKLastSync = 0,
    HEMDebugInfoUsageSysAlertShownLast31Days = 1,
    HEMDebugInfoUsageAppLaunchesLast31Days = 2,
    HEMDebugInfoUsageTimelineShownWithDataLast31Days = 3,
    HEMDebugInfoUsageAppReviewPromptCompleted = 4,
    HEMDebugInfoUsageAppReviewedThisVersion = 5,
    HEMDebugInfoUsageAppReviewStopAsking = 6,
    HEMDebugInfoUsageRows = 7
};

@implementation HEMDebugInfoDataSource

- (NSUInteger)numberOfInfoSections {
    return HEMDebugInfoSections;
}

- (NSUInteger)numberOfInfoRowsInSection:(NSUInteger)section {
    switch (section) {
        case HEMDebugInfoSectionApp:
            return HEMDebugInfoAppRows;
        case HEMDebugInfoSectionConfig:
            return HEMDebugInfoConfigRows;
        case HEMDebugInfoSectionUsage:
            return HEMDebugInfoUsageRows;
        default:
            return 0;
    }
}

- (NSString*)infoTitleForIndexPath:(NSIndexPath*)indexPath {
    // we do not care about the text that is returned from here being localized
    // as this will not be shown to app store users
    NSUInteger row = [indexPath row];
    switch ([indexPath section]) {
        case HEMDebugInfoSectionApp:
            return [self titleForAppInfoForRow:row];
        case HEMDebugInfoSectionConfig:
            return [self titleForConfigInfoForRow:row];
        case HEMDebugInfoSectionUsage:
            return [self titleForUsageInfoForRow:row];
        default:
            return nil;
    }
}

- (NSString*)infoValueForIndexPath:(NSIndexPath*)indexPath {
    NSUInteger row = [indexPath row];
    switch ([indexPath section]) {
        case HEMDebugInfoSectionApp:
            return [self valueForAppInfoForRow:row];
        case HEMDebugInfoSectionConfig:
            return [self valueForConfigInfoForRow:row];
        case HEMDebugInfoSectionUsage:
            return [self valueForUsageInfoForRow:row];
        default:
            return nil;
    }
}

#pragma mark - App Info

- (NSString*)titleForAppInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoAppRowVersion:
            return @"version";
        case HEMDebugInfoAppRowAccountId:
            return @"account id";
        default:
            return nil;
    }
}

- (NSString*)valueForAppInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoAppRowVersion: {
            NSBundle* bundle = [NSBundle mainBundle];
            return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        }
        case HEMDebugInfoAppRowAccountId: {
            NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
            return accountId ?: @"not set";
        }
        default:
            return nil;
    }
}

#pragma mark - Config Info

- (NSString*)titleForConfigInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoConfigApiURL:
            return @"api host";
        case HEMDebugInfoConfigClientId:
            return @"api client id";
        case HEMDebugInfoConfigZendeskClientId:
            return @"zendesk client id";
        case HEMDebugInfoConfigZendeskToken:
            return @"zendesk token";
        case HEMDebugInfoConfigMixpanelToken:
            return @"mixpanel token";
        case HEMDebugInfoConfigAppReviewURL:
            return @"app review url";
        case HEMDebugInfoConfigForgotPwURL:
            return @"forgot pw url";
        default:
            return nil;
    }
}

- (NSString*)valueForConfigInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoConfigApiURL:
            return [HEMConfig stringForConfig:HEMConfAPIURL];
        case HEMDebugInfoConfigClientId:
            return [HEMConfig stringForConfig:HEMConfClientId];
        case HEMDebugInfoConfigZendeskClientId:
            return [HEMConfig stringForConfig:HEMConfZendeskClientId];
        case HEMDebugInfoConfigZendeskToken:
            return [HEMConfig stringForConfig:HEMConfZendeskToken];
        case HEMDebugInfoConfigMixpanelToken:
            return [HEMConfig stringForConfig:HEMConfAnalyticsToken];
        case HEMDebugInfoConfigAppReviewURL:
            return [HEMConfig stringForConfig:HEMConfAppReviewURL];
        case HEMDebugInfoConfigForgotPwURL:
            return [HEMConfig stringForConfig:HEMConfPassResetURL];
        default:
            return nil;
    }
}

#pragma mark - Usage Info

- (NSString*)titleForUsageInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoUsageHKLastSync:
            return @"health, night last sync";
        case HEMDebugInfoUsageSysAlertShownLast31Days:
            return @"# sys alerts (31 days)";
        case HEMDebugInfoUsageAppLaunchesLast31Days:
            return @"# app launches (31 days)";
        case HEMDebugInfoUsageTimelineShownWithDataLast31Days:
            return @"# timeline shown (31 days)";
        case HEMDebugInfoUsageAppReviewPromptCompleted:
            return @"days since last review prompt";
        case HEMDebugInfoUsageAppReviewedThisVersion:
            return @"review completed this version";
        case HEMDebugInfoUsageAppReviewStopAsking:
            return @"stop asking to review";
        default:
            return nil;
    }
}

- (NSString*)valueForUsageInfoForRow:(NSUInteger)row {
    switch (row) {
        case HEMDebugInfoUsageHKLastSync: {
            return [[[HEMHealthKitService sharedService] lastSyncDate] timeAgo];
        }
        case HEMDebugInfoUsageSysAlertShownLast31Days: {
            HEMAppUsage* usage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageSystemAlertShown];
            return [NSString stringWithFormat:@"%ld", (long)[usage usageWithin:HEMAppUsageIntervalLast31Days]];
        }
        case HEMDebugInfoUsageAppLaunchesLast31Days: {
            HEMAppUsage* usage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppLaunched];
            return [NSString stringWithFormat:@"%ld", (long)[usage usageWithin:HEMAppUsageIntervalLast31Days]];
        }
        case HEMDebugInfoUsageTimelineShownWithDataLast31Days: {
            HEMAppUsage* usage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
            return [NSString stringWithFormat:@"%ld", (long)[usage usageWithin:HEMAppUsageIntervalLast31Days]];
        }
        case HEMDebugInfoUsageAppReviewPromptCompleted: {
            HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
            return [NSString stringWithFormat:@"%ld", [[appUsage updated] daysElapsed]];
        }
        case HEMDebugInfoUsageAppReviewedThisVersion: {
            return [HEMAppReview hasNotYetReviewedThisVersion] ? @"no" : @"yes";
        }
        case HEMDebugInfoUsageAppReviewStopAsking:
            return [HEMAppReview hasStatedToStopAsking] ? @"yes" : @"no";
        default:
            return nil;
    }
}

@end
