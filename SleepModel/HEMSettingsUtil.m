//
//  HEMSettingsUtil.m
//  Sense
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAuthorizationService.h>
#import "HEMSettingsUtil.h"

static NSString* const HEMSettingsEnableHealthKit = @"is.hello.settings.healthkit";

@implementation HEMSettingsUtil

+ (NSString*)accountSpecificSettingsKey:(NSString*)key {
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    return [NSString stringWithFormat:@"%@.%@",HEMSettingsEnableHealthKit, accountId];
}

+ (void)enableHealthKit:(BOOL)enable {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enable forKey:[self accountSpecificSettingsKey:HEMSettingsEnableHealthKit]];
    [defaults synchronize];
}

+ (BOOL)isHealthKitEnabled {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:[self accountSpecificSettingsKey:HEMSettingsEnableHealthKit]];
}

@end
