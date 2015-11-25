//
//  HEMSegmentProvider.m
//  Sense
//
//  Created by Jimmy Lu on 11/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Analytics/SEGAnalytics.h>

#import <SenseKit/SENAuthorizationService.h>

#import "HEMSegmentProvider.h"

@interface HEMSegmentProvider()

@property (strong, nonatomic) NSMutableDictionary* globalEventProperties;

@end

@implementation HEMSegmentProvider

- (instancetype)initWithWriteKey:(NSString*)writeKey {
    self = [super init];
    if (self) {
        _globalEventProperties = [NSMutableDictionary dictionary];
        [self configureWithKey:writeKey];
        [self listenForApplicationEvents];
    }
    return self;
}

- (void)configureWithKey:(NSString*)key {
    SEGAnalyticsConfiguration* config = [SEGAnalyticsConfiguration configurationWithWriteKey:key];
    [SEGAnalytics setupWithConfiguration:config];
    DDLogVerbose(@"configured segment %@", config);
}

#pragma mark - Application Activities

- (void)listenForApplicationEvents {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(willEnterBackground)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];
}

- (void)willEnterBackground {
    SEGAnalytics* segment = [SEGAnalytics sharedAnalytics];
    [segment flush];
}

#pragma mark - Sign Up

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    SEGAnalytics* segment = [SEGAnalytics sharedAnalytics];
    // alias it, then flush it to make sure that is processed first
    [segment alias:userId];
    [segment flush];
    // set user traits without identifying since it seems to break the funnel
    [segment identify:nil traits:properties];
}

#pragma mark - Sign Out

- (void)reset:(NSString*)userId {
    [[self globalEventProperties] removeAllObjects];
    SEGAnalytics* segment = [SEGAnalytics sharedAnalytics];
    [segment reset];
}

#pragma mark - Sign In / App Launches

- (void)setUserId:(NSString *)userId withProperties:(NSDictionary *)properties {
    SEGAnalytics* segment = [SEGAnalytics sharedAnalytics];
    [segment identify:userId traits:properties];
}

#pragma mark - Tracking

- (void)setGlobalEventProperties:(NSMutableDictionary *)globalEventProperties {
    [[self globalEventProperties] addEntriesFromDictionary:globalEventProperties];
}

- (void)setUserProperties:(NSDictionary *)properties {
    [[SEGAnalytics sharedAnalytics] identify:nil traits:properties];
}

- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties {
    NSMutableDictionary* eventProps =
        [NSMutableDictionary dictionaryWithDictionary:[self globalEventProperties]];

    if ([properties count] > 0) {
        [eventProps addEntriesFromDictionary:properties];
    }
    
    [[SEGAnalytics sharedAnalytics] track:eventName properties:eventProps];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
