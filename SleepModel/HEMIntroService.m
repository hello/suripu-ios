//
//  HEMIntroService.m
//  Sense
//
//  Created by Jimmy Lu on 8/31/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENLocalPreferences.h>
#import "HEMIntroService.h"

static NSString* const kHEMIntroKeyRoomConditons = @"intro.room.conditions.views";
static NSUInteger const kHEMIntroMinCount = 2;

@implementation HEMIntroService

- (BOOL)shouldIntroduceType:(HEMIntroType)type {
    NSNumber* views = [self viewCountForType:type];
    return [self shouldIntroWithCount:views];
}

- (void)incrementIntroViewsForType:(HEMIntroType)introType {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    NSString* key = [self keyForType:introType];
    NSNumber* views = [localPrefs userPreferenceForKey:key];
    
    if (views) {
        views = @([views unsignedIntegerValue] + 1);
    } else {
        views = @1;
    }
    
    [localPrefs setUserPreference:views forKey:key];
}

#pragma mark - Helpers

- (NSString*)keyForType:(HEMIntroType)type {
    switch (type) {
        case HEMIntroTypeRoomConditions:
            return kHEMIntroKeyRoomConditons;
        default:
            return nil;
    }
}

- (BOOL)shouldIntroWithCount:(NSNumber*)count {
    return [count unsignedIntegerValue] <= kHEMIntroMinCount;
}

- (NSNumber*)viewCountForType:(HEMIntroType)type {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return [localPrefs userPreferenceForKey:[self keyForType:type]];
}

@end
