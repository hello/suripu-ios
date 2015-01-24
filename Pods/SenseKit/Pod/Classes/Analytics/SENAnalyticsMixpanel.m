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
    
    [Mixpanel sharedInstanceWithToken:dictionary[kSENAnalyticsProviderToken]];

}

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    [mp createAlias:userId forDistinctID:[mp distinctId]];
    [self setUserId:userId withProperties:properties];
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
//    [[Mixpanel sharedInstance] timeEvent:eventName];
}

- (void)endEvent:(NSString *)eventName {
    [[Mixpanel sharedInstance] track:eventName];
}

@end
