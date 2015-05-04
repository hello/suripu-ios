//
//  SENAnalyticsMixpanel.m
//  Pods
//
//  Created by Jimmy Lu on 12/12/14.
//
//
#import <Mixpanel/Mixpanel.h>
#import "SENAnalyticsMixpanel.h"

@implementation SENAnalyticsMixpanel

- (void)configureWithProperties:(NSDictionary*)dictionary {
#if DEBUG
    // we need to crash the app in debug if it was not configured properly.  Otherwise
    // all tracked events will just disappear or worse ...
    NSAssert(dictionary != nil && dictionary[kSENAnalyticsProviderToken] != nil,
             @"provider token is required");
#endif
    
    Mixpanel* mixpanel = [Mixpanel sharedInstanceWithToken:dictionary[kSENAnalyticsProviderToken]];
    mixpanel.checkForNotificationsOnActive = YES;
    mixpanel.checkForSurveysOnActive = YES;
}

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    NSString* origDistinctId = [[mp distinctId] copy];
    [mp createAlias:userId forDistinctID:origDistinctId];
    // per Mixpanel, we need to use mixpanel's original distinct id when we
    // identify the user while creating the alias to prevent a race condition
    // where identify: completes before the createAlias:forDistinctId call, causing
    // people profiles to never show up
    [self setUserId:origDistinctId withProperties:properties];
}

- (void)setUserId:(NSString*)userId withProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    NSString* identifier = userId ?: [mp distinctId];
    [mp identify:identifier];
    
    if ([properties count] > 0) {
        [[mp people] set:properties];
    }
}

- (void)setGlobalEventProperties:(NSDictionary *)properties {
    if ([properties count] == 0) return;
    [[Mixpanel sharedInstance] registerSuperProperties:properties];
}

- (void)setUserProperties:(NSDictionary*)properties {
    [[[Mixpanel sharedInstance] people] set:properties];
}

- (void)track:(NSString*)eventName withProperties:(NSDictionary*)properties {
    [[Mixpanel sharedInstance] track:eventName properties:properties];
}

- (void)startEvent:(NSString *)eventName {
    [[Mixpanel sharedInstance] timeEvent:eventName];
}

- (void)endEvent:(NSString *)eventName {
    [[Mixpanel sharedInstance] track:eventName];
}

@end
