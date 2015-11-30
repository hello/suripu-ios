//
//  SENAnalytics.m
//  Pods
//
//  Created by Jimmy Lu on 10/20/14.
//
//

#import "SENAnalytics.h"
#import "SENAuthorizationService.h"

NSString* const kSENAnalyticsPropConnection = @"connection";
NSString* const kSENAnalyticsPropCode = @"code";
NSString* const kSENAnalyticsPropMessage = @"message";
NSString* const kSENAnalyticsPropDomain = @"domain";

@implementation SENAnalytics

static NSMutableDictionary* providers;

+ (void)addProvider:(id<SENAnalyticsProvider>)provider {
    if (!providers) {
        providers = [NSMutableDictionary new];
    }
    NSString* providerName = NSStringFromClass([provider class]);
    providers[providerName] = provider;
}

+ (void)setUserId:(NSString*)userId properties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider setUserId:userId withProperties:properties];
    }];
}

+ (void)userWithId:(NSString*)userId didSignUpWithProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider userWithId:userId didSignupWithProperties:properties];
    }];
}

+ (void)setGlobalEventProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        if ([provider respondsToSelector:@selector(setGlobalEventProperties:)]) {
            [provider setGlobalEventProperties:properties];
        }
    }];
}

+ (void)setUserProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        if ([provider respondsToSelector:@selector(setUserProperties:)]) {
            [provider setUserProperties:properties];
        }
    }];
}

+ (void)track:(NSString*)eventName {
    [self track:eventName properties:nil];
}

+ (void)track:(NSString*)eventName properties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider track:eventName withProperties:properties];
    }];
}

+ (void)trackError:(NSError*)error withEventName:(NSString*)eventName {
    NSMutableDictionary* mutableProps = [NSMutableDictionary dictionaryWithCapacity:2];
    if ([error isKindOfClass:[NSError class]]) { // making sure error is an error.  sometimes it can be NSNull...
        [mutableProps setValue:@([error code]) forKey:kSENAnalyticsPropCode];
        [mutableProps setValue:[error localizedDescription] forKey:kSENAnalyticsPropMessage];
        [mutableProps setValue:[error domain] forKey:kSENAnalyticsPropDomain];
    }
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider track:eventName withProperties:mutableProps];
    }];
}

+ (void)reset:(NSString*)userId {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        if ([provider respondsToSelector:@selector(reset:)]) {
            [provider reset:userId];
        }
    }];
}

@end
