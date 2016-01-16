//
//  HEMTimelineService.m
//  Sense
//
//  Created by Jimmy Lu on 1/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENAccount.h>

#import "HEMTimelineService.h"
#import "HEMOnboardingService.h"
#import "NSDate+HEMRelative.h"

static NSString* const HEMTimelineSettingsAccountCreationDate = @"account.creation.date";

@implementation HEMTimelineService

- (BOOL)isFirstNightOfSleep:(NSDate*)date forAccount:(SENAccount*)account {
    SENLocalPreferences* localPreferences = [SENLocalPreferences sharedPreferences];
    NSDate* creationDate = [localPreferences userPreferenceForKey:HEMTimelineSettingsAccountCreationDate];
    if (!creationDate) {
        creationDate = [account createdAt];
        [localPreferences setUserPreference:creationDate forKey:HEMTimelineSettingsAccountCreationDate];
    }
    return [creationDate isOnSameDay:date];
}

@end
