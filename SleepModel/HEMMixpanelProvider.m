//
//  HEMMixpanelProvider.m
//  Sense
//
//  Created by Jimmy Lu on 11/25/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <Mixpanel/Mixpanel.h>

#import "HEMMixpanelProvider.h"

@interface HEMMixpanelProvider()

@end

@implementation HEMMixpanelProvider

- (nonnull instancetype)initWithToken:(nonnull NSString*)token {
    self = [super init];
    if (self) {
        [Mixpanel sharedInstanceWithToken:token];
        [self listenForApplicationEvents];
    }
    return self;
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
    [[Mixpanel sharedInstance] flush];
}

#pragma mark - Sign Up

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    NSString* distinctId = [mp distinctId];
    [mp createAlias:userId forDistinctID:distinctId];
    [mp flush];
    [mp identify:distinctId];
}

#pragma mark - Sign Out

- (void)reset:(NSString*)userId {
    Mixpanel* mp = [Mixpanel sharedInstance];
    [mp reset];
}

#pragma mark - Sign In / App Launches

- (void)setUserId:(NSString *)userId withProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    [mp identify:userId];
    [[mp people] set:properties];
}

#pragma mark - Tracking

- (void)setGlobalEventProperties:(NSDictionary *)globalEventProperties {
    [[Mixpanel sharedInstance] registerSuperProperties:globalEventProperties];
}

- (void)setUserProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    [[mp people] set:properties];
}

- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties {
    Mixpanel* mp = [Mixpanel sharedInstance];
    [mp track:eventName properties:properties];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
