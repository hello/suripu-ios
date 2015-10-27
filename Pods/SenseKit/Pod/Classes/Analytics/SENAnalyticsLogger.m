
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "SENAnalyticsLogger.h"
#import "SENAnalyticsProvider.h"

@interface SENAnalyticsLogger()

@property (nonatomic, strong) NSMutableDictionary* globalProperties;

@end

@implementation SENAnalyticsLogger

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

- (id)init {
    self = [super init];
    if (self) {
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

@end
