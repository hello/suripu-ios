//
//  SENAnalyticsProvider.h
//  Pods
//
//  Simple protocol that details the methods required for SENAnalytics to function
//
//  Created by Jimmy Lu on 10/20/14.
//
//

static NSString* const kSENAnalyticsProviderToken = @"kSENAnalyticsProviderToken";

@protocol SENAnalyticsProvider <NSObject>

/**
 * @method
 * Configure the provider with the specified properties, which should include the
 * kSENAnalyticsProviderToken key
 *
 * @param properties: the properties specific to the provider
 */
- (void)configureWithProperties:(NSDictionary*)properties;

/**
 * @method
 * Set the unique identifier that maps to the current user of the application
 * with optional properties to attach to the user
 *
 * @param userId:     the unique identifier of the user
 * @param properties: additional info about the user
 */
- (void)setUserId:(NSString*)userId withProperties:(NSDictionary*)properties;

/**
 * @method
 * Track the event by name with optional details of the events
 * 
 * @param eventName:  the name of the event
 * @param properties: additional information about the event
 */
- (void)track:(NSString*)eventName withProperties:(NSDictionary*)properties;

@end
