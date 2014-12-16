
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDLogMacros.h>
#import "SENAnalyticsLogger.h"
#import "SENAnalyticsProvider.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

@interface SENAnalyticsLogger()

@property (nonatomic, strong) NSMutableDictionary* timedEvents;
@property (nonatomic, strong) NSMutableDictionary* globalProperties;

@end

@implementation SENAnalyticsLogger

- (id)init {
    self = [super init];
    if (self) {
        [self setTimedEvents:[NSMutableDictionary dictionary]];
        [self setGlobalEventProperties:[NSMutableDictionary dictionary]];
    }
    return self;
}

- (void)configureWithProperties:(NSDictionary *)properties {
    [self logEvent:@"Configured Logger" withProperties:properties];
}

- (void)userWithId:(NSString *)userId didSignupWithProperties:(NSDictionary *)properties {
    NSString* event = [NSString stringWithFormat:@"User signed up with id %@", userId];
    [self logEvent:event withProperties:properties];
}

- (void)setUserId:(NSString *)userId withProperties:(NSDictionary *)properties {
    NSDictionary* userProperties = properties;
    if (userId != nil) {
        NSMutableDictionary* dict = userProperties.mutableCopy;
        dict[@"user"] = userId;
        userProperties = dict;
    }
    [self logEvent:@"Set User ID" withProperties:userProperties];
}

- (void)setGlobalEventProperties:(NSDictionary *)properties {
    [[self globalProperties] addEntriesFromDictionary:properties];
}

- (void)setUserProperties:(NSDictionary*)properties {
    [self logEvent:@"Setting user properties " withProperties:properties];
}

- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties {
    NSMutableDictionary* gProps = [[self globalProperties] mutableCopy];
    [gProps addEntriesFromDictionary:properties];
    [self logEvent:eventName withProperties:gProps];
}

- (void)logEvent:(NSString*)name withProperties:(NSDictionary*)properties {
    DDLogVerbose(@"[%@] : %@", name, properties ?: @"");
}

- (void)startEvent:(NSString *)eventName {
    [[self timedEvents] setValue:[NSDate date] forKey:eventName];
}

- (void)endEvent:(NSString *)eventName {
    NSDate* startTime = [[self timedEvents] valueForKey:eventName];
    if (startTime != nil) {
        NSTimeInterval elapsed = abs([startTime timeIntervalSinceNow]);
        NSString* event = [NSString stringWithFormat:@"%@ took %0.2f", eventName, elapsed];
        [self logEvent:event withProperties:nil];
        [[self timedEvents] removeObjectForKey:eventName];
    }
}

@end
