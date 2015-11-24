//
//  HEMSegmentProvider.m
//  Sense
//
//  Created by Jimmy Lu on 11/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Analytics/Analytics.h>

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
    }
    return self;
}

- (void)configureWithKey:(NSString*)key {
    SEGAnalyticsConfiguration* config = [SEGAnalyticsConfiguration configurationWithWriteKey:key];
    [config setFlushAt:1];
    [SEGAnalytics setupWithConfiguration:config];
    DDLogVerbose(@"configured segment analytics");
}

#pragma mark - Sign Up

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    SEGAnalytics* segment = [SEGAnalytics sharedAnalytics];
    [segment alias:userId];
    [segment identify:nil traits:properties];
}

#pragma mark - Sign Out

- (void)reset:(NSString*)userId {
    [[self globalEventProperties] removeAllObjects];
    [[SEGAnalytics sharedAnalytics] reset];
}

#pragma mark - Sign In / App Launches

- (void)setUserId:(NSString *)userId withProperties:(NSDictionary *)properties {
    [[SEGAnalytics sharedAnalytics] identify:userId traits:properties];
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

@end
