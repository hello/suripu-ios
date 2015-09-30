//
//  SENAnalyticsMixpanel.m
//  Pods
//
//  Created by Jimmy Lu on 12/12/14.
//
//
#import <Mixpanel-simple/Mixpanel.h>
#import <Mixpanel-simple/MPTracker.h>
#import <Mixpanel-simple/MPPeople.h>
#import "SENAnalyticsMixpanel.h"

@interface SENAnalyticsMixpanel ()
@property (nonatomic,strong) Mixpanel* mixpanel;
@end

@implementation SENAnalyticsMixpanel

NSString* const SENAMCacheDirectory = @"MixpanelCache";

- (void)configureWithProperties:(NSDictionary*)dictionary {
#if DEBUG
    // we need to crash the app in debug if it was not configured properly.  Otherwise
    // all tracked events will just disappear or worse ...
    NSAssert(dictionary != nil && dictionary[kSENAnalyticsProviderToken] != nil,
             @"provider token is required");
#endif
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:SENAMCacheDirectory];
    BOOL isDir = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && exists))
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    self.mixpanel = [[Mixpanel alloc] initWithToken:dictionary[kSENAnalyticsProviderToken]
                                     cacheDirectory:[NSURL URLWithString:path]];
}

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    MPTracker* tracker = self.mixpanel.tracker;
    NSString* origDistinctId = [[tracker distinctId] copy];
    [tracker createAlias:userId forDistinctID:origDistinctId];
    // per Mixpanel, we need to use mixpanel's original distinct id when we
    // identify the user while creating the alias to prevent a race condition
    // where identify: completes before the createAlias:forDistinctId call, causing
    // people profiles to never show up
    [self setUserId:origDistinctId withProperties:properties];
}

- (void)setUserId:(NSString*)userId withProperties:(NSDictionary *)properties {
    NSString* identifier = userId ?: [self.mixpanel.tracker distinctId];
    [self.mixpanel identify:identifier];
    if (properties.count > 0)
        [self.mixpanel.people setUserProperties:properties];
}

- (void)setGlobalEventProperties:(NSDictionary *)properties {
    if ([properties count] == 0) return;
    MPTracker* tracker = self.mixpanel.tracker;
    tracker.defaultProperties = properties;
}

- (void)setUserProperties:(NSDictionary*)properties {
    if (properties.count > 0)
        [self.mixpanel.people setUserProperties:properties];
}

- (void)track:(NSString*)eventName withProperties:(NSDictionary*)properties {
    [self.mixpanel.tracker track:eventName properties:properties];
}

@end
