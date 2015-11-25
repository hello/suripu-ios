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
 * @method userWithId:didSignupWithProperties
 *
 * @discussion
 * Track the user signing up.  For some providers, special operations are needed to
 * properly link the user before sign up to events after sign up.
 *
 * This method will / should only be called once in the life time of a user's account.
 *
 * @param userId:     the identifier of the user generated by application post sign up
 * @param properties: optional user properties to associate with the user
 */
- (void)userWithId:(NSString*)userId didSignupWithProperties:(NSDictionary*)properties;

/**
 * @method
 * Set the unique identifier that maps to the current user of the application
 * with optional properties to attach to the user.  Useful for when user is 
 * authenticating in to the application.
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

@optional
/**
 * @method
 * setGlobalEventProperties:
 *
 * @discussion
 * Set properties that will be sent up with all events tracked automatically
 *
 * @param properties: properties to be set on all events to be tracked
 */
- (void)setGlobalEventProperties:(NSDictionary*)properties;

/**
 * @method
 * Set the user properties, which assumes the user has already be set with setUserId
 * or with userWithId:didSignupWithProperties:
 *
 * @param properties: properties to be set on to the user
 */
- (void)setUserProperties:(NSDictionary*)properties;

/**
 * @method
 * Should be linked to a sign out option in the application. Provider should 
 * clean up / clear any cache that might be related to current user
 *
 * @param userId:     the unique identifier of the user
 */
- (void)reset:(NSString*)userId;

@end