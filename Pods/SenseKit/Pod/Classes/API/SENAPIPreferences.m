//
//  SENAPIPreferences.m
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import "SENAPIPreferences.h"
#import "SENLocalPreferences.h"
#import "SENPreference.h"
#import "SENAPIClient.h"

@implementation SENAPIPreferences

NSString* const SENAPIPreferenceV2ResourceName = @"v2/account/preferences";

+ (void)updatePreferencesWithCompletion:(SENAPIDataBlock)completion {
    [SENAPIClient PUT:SENAPIPreferenceV2ResourceName
           parameters:[self preferencesToDict]
           completion:^(id data, NSError *error) {
               if (!completion) return;
               NSDictionary* preferences = nil;
               if (!error)
                   preferences = [self preferencesFromDict:data];
               completion (preferences, error);
           }];
}

+ (void)getPreferences:(SENAPIDataBlock)completion {
    if (!completion) return;
    
    [SENAPIClient GET:SENAPIPreferenceV2ResourceName
           parameters:nil
           completion:^(NSDictionary* data, NSError *error) {
        NSDictionary* preferences = nil;
        if (!error)
            preferences = [self preferencesFromDict:data];
        completion (preferences, error);
    }];
}

+ (NSDictionary*)preferencesFromDict:(NSDictionary*)data {
    if (![data isKindOfClass:[NSDictionary class]])
        return nil;
    __block NSMutableDictionary* preferences = [NSMutableDictionary dictionary];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSNumber *obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSNumber class]]) {
            SENPreference* pref = [[SENPreference alloc] initWithName:key value:obj];
            if (pref)
                preferences[@([pref type])] = pref;
        }
    }];
    return preferences;
}

+ (NSDictionary*)preferencesToDict {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    NSArray* keys = @[SENPreferenceNameTime, SENPreferenceNameTemp, SENPreferenceNameWeightMetric, SENPreferenceNameHeightMetric, SENPreferenceNamePushScore, SENPreferenceNameEnhancedAudio, SENPreferenceNamePushConditions];
    NSMutableDictionary* values = [[NSMutableDictionary alloc] initWithCapacity:[keys count]];
    for (NSString* key in keys) {
        [values setValue:[prefs userPreferenceForKey:key] forKey:key];
    }
    return values;
}

@end
