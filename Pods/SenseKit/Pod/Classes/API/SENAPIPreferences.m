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

static NSString* const SENAPIPreferenceResourceName = @"preferences";

@implementation SENAPIPreferences

+ (void)updatePreference:(SENPreference*)preference completion:(SENAPIDataBlock)completion {
    [SENAPIClient PUT:SENAPIPreferenceResourceName
           parameters:[preference dictionaryValue]
           completion:^(id data, NSError *error) {
               if (!completion) return;
               
               SENPreference* updatedPreference = nil;
               if ([data isKindOfClass:[NSDictionary class]]) {
                   updatedPreference = [[SENPreference alloc] initWithDictionary:data];
               }
               completion (updatedPreference, error);
           }];
}

@end
