//
//  HEMConfig.m
//  Sense
//
//  These keys are mostly found in corresponding Info.plist files, which would
//  point to user defined variables that are specific to the build configuration.
//
//  Created by Jimmy Lu on 2/23/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMConfig.h"

static NSString* const HEMConfigAPIPlistKey = @"SenseApiUrl";
static NSString* const HEMConfigClientIdPlistKey = @"SenseClientId";
static NSString* const HEMConfigAnalyticsTokenPlistKey = @"SenseAnalyticsToken";
static NSString* const HEMConfigCrashTokenPlistKey = @"SenseCrashReportsToken";
static NSString* const HEMConfigAppReviewURLPlistKey = @"SenseAppReviewURL";

// This flag indicates whether or not the app should be able to shake to show
// an action sheet of debug options. this should be tied to feature flags on
// server, but until then, leave it here.
static NSString* const HEMConfigAllowSupportOptions = @"SenseAllowSupportOptions";

// Zendesk SDK configurations
static NSString* const HEMConfigZendeskTokenPlistKey = @"SenseZendeskToken";
static NSString* const HEMConfigZendeskURLPlistKey = @"SenseZendeskURL";
static NSString* const HEMConfigZendeskClientIdPlistKey = @"SenseZendeskClientId";

@implementation HEMConfig

+ (NSString*)stringForConfig:(HEMConf)config {
    NSBundle* bundle = [NSBundle mainBundle];
    switch (config) {
        case HEMConfAPIURL:
            return [bundle objectForInfoDictionaryKey:HEMConfigAPIPlistKey];
        case HEMConfClientId:
            return [bundle objectForInfoDictionaryKey:HEMConfigClientIdPlistKey];
        case HEMConfAnalyticsToken:
            return [bundle objectForInfoDictionaryKey:HEMConfigAnalyticsTokenPlistKey];
        case HEMConfCrashlyticsToken:
            return [bundle objectForInfoDictionaryKey:HEMConfigAnalyticsTokenPlistKey];
        case HEMConfAllowDebugOptions:
            return [bundle objectForInfoDictionaryKey:HEMConfigAllowSupportOptions];
        case HEMConfZendeskToken:
            return [bundle objectForInfoDictionaryKey:HEMConfigZendeskTokenPlistKey];
        case HEMConfZendeskURL:
            return [bundle objectForInfoDictionaryKey:HEMConfigZendeskURLPlistKey];
        case HEMConfZendeskClientId:
            return [bundle objectForInfoDictionaryKey:HEMConfigZendeskClientIdPlistKey];
        case HEMConfAppReviewURL:
            return [bundle objectForInfoDictionaryKey:HEMConfigAppReviewURLPlistKey];
        default:
            return nil;
    }
}

+ (BOOL)booleanForConfig:(HEMConf)config {
    return [[self stringForConfig:config] boolValue];
}

@end

