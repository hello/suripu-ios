//
//  HEMSegmentProvider.m
//  Sense
//
//  Created by Jimmy Lu on 11/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Analytics/SEGAnalytics.h>

#import <SenseKit/SENAuthorizationService.h>

#import "UIDevice+HEMUtils.h"

#import "HEMSegmentProvider.h"

// traits = global properties require iOS prefix to not overwrite android props
static NSString* const HEMSegmentTraitAppVersionName = @"iOS App Version";
static NSString* const HEMSegmentTraitDeviceModelName = @"iOS Device Model";
static NSString* const HEMSegmentTraitOSVersionName = @"iOS Version";
static NSString* const HEMSegmentTraitCountryCode = @"Country Code";

@interface HEMSegmentProvider()

@property (strong, nonatomic) NSMutableDictionary* globalEventProperties;
@property (strong, nonatomic) NSDictionary* defaultTraits;

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

- (NSDictionary*)defaultTraits {
    if (!_defaultTraits) {
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        NSString* deviceModel = [UIDevice currentDeviceModel];
        NSString* appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString* iOSVersion = [[UIDevice currentDevice] systemVersion];
        _defaultTraits = @{HEMSegmentTraitAppVersionName : appVersion,
                           HEMSegmentTraitDeviceModelName : deviceModel,
                           HEMSegmentTraitOSVersionName : iOSVersion,
                           HEMSegmentTraitCountryCode : countryCode};
    }
    return _defaultTraits;
}

- (void)configureWithKey:(NSString*)key {
    SEGAnalyticsConfiguration* config = [SEGAnalyticsConfiguration configurationWithWriteKey:key];
    [config setFlushAt:2]; // prevent user killing the app from destroying our analytics
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
    NSMutableDictionary* traits = [[self defaultTraits] mutableCopy];
    if (properties) {
        [traits addEntriesFromDictionary:properties];
    }
    [segment identify:nil traits:traits];
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
    NSMutableDictionary* traits = [[self defaultTraits] mutableCopy];
    if (properties) {
        [traits addEntriesFromDictionary:properties];
    }
    [segment identify:userId traits:traits];
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
