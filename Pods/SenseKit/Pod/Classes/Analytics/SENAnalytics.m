//
//  SENAnalytics.m
//  Pods
//
//  Created by Jimmy Lu on 10/20/14.
//
//

#import "SENAnalytics.h"
#import "SENAuthorizationService.h"
#import "SENAnalyticsAmplitude.h"

NSString* const kSENAnalyticsConfigAPIKey = @"kSENAnalyticsConfigAPIKey";
NSString* const kSENAnalyticsPropConnection = @"connection";
NSString* const kSENAnalyticsPropCode = @"code";
NSString* const kSENAnalyticsPropMessage = @"message";

static id<SENAnalyticsProvider> provider;

@implementation SENAnalytics

+ (void)configure:(SENAnalyticsProviderName)name with:(NSDictionary*)properties {
    switch (name) {
        case SENAnalyticsProviderNameAmplitude:
            provider = [[SENAnalyticsAmplitude alloc] init];
            break;
        default:
            break;
    }
    
    [provider configureWithProperties:properties];
}

+ (void)setUserId:(NSString*)userId properties:(NSDictionary*)properties {
    if (provider == nil) return;
    
    [provider setUserId:userId withProperties:properties];
}

+ (void)track:(NSString*)eventName {
    [self track:eventName properties:nil];
}

+ (void)track:(NSString*)eventName properties:(NSDictionary*)properties {
    if (provider == nil) return;
    
    [provider track:eventName withProperties:properties];
}

+ (void)trackError:(NSError*)error withEventName:(NSString*)eventName {
    if (provider == nil) return;
    
    NSMutableDictionary* mutableProps = [NSMutableDictionary dictionaryWithCapacity:2];
    [mutableProps setValue:@([error code]) forKey:kSENAnalyticsPropCode];
    [mutableProps setValue:[error description] forKey:kSENAnalyticsPropMessage];
    [provider track:eventName withProperties:mutableProps];
}

@end
