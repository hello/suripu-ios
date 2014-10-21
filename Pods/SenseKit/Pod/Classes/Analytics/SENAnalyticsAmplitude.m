//
//  SENAnalyticsAmplitude.m
//  Pods
//
//  Created by Jimmy Lu on 10/20/14.
//
//
#import "Amplitude.h"
#import "SENAnalyticsProvider.h"
#import "SENAnalyticsAmplitude.h"

@implementation SENAnalyticsAmplitude

- (void)configureWithProperties:(NSDictionary*)dictionary {
#if DEBUG
    // we need to crash the app in debug if it was not configured properly.  Otherwise
    // all tracked events will just disappear or worse ...
    NSAssert(dictionary != nil && dictionary[kSENAnalyticsProviderToken] != nil,
             @"provider token is required");
#endif
    [Amplitude initializeApiKey:dictionary[kSENAnalyticsProviderToken]];
}

- (void)setUserId:(NSString*)userId withProperties:(NSDictionary *)properties {
    // if userId is nil, simply set it back to the device id, in case user signs
    // out or is forcefully logged out.  Before setting userId for the first time,
    // this is exactly what Amplitude does.  However, once set, it won't be removed
    // if nil is passed in.
    NSString* identifier = userId == nil ? [Amplitude getDeviceId] : userId;
    
    [Amplitude setUserId:identifier];
    [Amplitude setUserProperties:properties];
}

- (void)track:(NSString*)eventName withProperties:(NSDictionary*)properties {
    [Amplitude logEvent:eventName withEventProperties:properties];
}

@end
