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

// This flag indicates whether or not the app should be able to shake to show
// an action sheet of debug options. this should be tied to feature flags on
// server, but until then, leave it here.
static NSString* const HEMConfigAllowSupportOptions = @"SenseAllowSupportOptions";

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
        default:
            return nil;
    }
}

+ (BOOL)booleanForConfig:(HEMConf)config {
    return [[self stringForConfig:config] boolValue];
}

@end

