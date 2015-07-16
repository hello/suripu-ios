//
//  SENAPIPreferences.m
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import "SENAPIPreferences.h"
#import "SENPreference.h"
#import "SENAPIClient.h"

static NSString* const SENAPIPreferenceResourceName = @"v1/preferences";

@implementation SENAPIPreferences

+ (void)updatePreference:(SENPreference*)preference completion:(SENAPIDataBlock)completion {
    [SENAPIClient PUT:SENAPIPreferenceResourceName
           parameters:[preference dictionaryValue]
           completion:^(id data, NSError *error) {
               if (!completion) return;
               
               SENPreference* updatedPreference = nil;
               if (error == nil && [data isKindOfClass:[NSDictionary class]]) {
                   updatedPreference = [[SENPreference alloc] initWithDictionary:data];
               }
               completion (updatedPreference, error);
           }];
}

+ (void)getPreferences:(SENAPIDataBlock)completion {
    if (!completion) return;
    
    [SENAPIClient GET:SENAPIPreferenceResourceName parameters:nil completion:^(id data, NSError *error) {
        NSMutableDictionary* preferences = nil;
        
        if (error == nil && [data isKindOfClass:[NSDictionary class]]) {
            SENPreference* pref = nil;
            preferences = [NSMutableDictionary dictionary];
            
            for (id keyObj in data) {
                if ([keyObj isKindOfClass:[NSString class]]) {
                    id valueObj = data[keyObj];
                    if ([valueObj isKindOfClass:[NSNumber class]]) {
                        pref = [[SENPreference alloc] initWithName:keyObj value:valueObj];
                        if (pref) {
                            preferences[@([pref type])] = pref;
                        }
                    }
                }
            }
        }
        
        completion (preferences, error);
    }];
}

@end
