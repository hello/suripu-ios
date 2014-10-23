
#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDLogMacros.h>
#import "SENAnalyticsLogger.h"
#import "SENAnalyticsProvider.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

@implementation SENAnalyticsLogger

- (void)configureWithProperties:(NSDictionary *)properties {
    [self logEvent:@"Configured Logger" withProperties:properties];
}

- (void)setUserId:(NSString *)userId withProperties:(NSDictionary *)properties {
    NSMutableDictionary* dict = properties.mutableCopy;
    dict[@"user"] = userId;
    [self logEvent:@"Set User ID" withProperties:dict];
}
- (void)track:(NSString *)eventName withProperties:(NSDictionary *)properties {
    [self logEvent:eventName withProperties:properties];
}

- (void)logEvent:(NSString*)name withProperties:(NSDictionary*)properties {
    DDLogVerbose(@"[%@] : %@", name, properties ?: @"");
}
@end
