//
//  SENAnalytics.h
//  Pods
//
//  This class represents a wrapper to our Analytics service provider so that we
//  interchange the provider without modifying the application.
//
//  Created by Jimmy Lu on 10/20/14.
//

#import <Foundation/Foundation.h>

#import "SENAnalyticsProvider.h"

/**
 * The providers this analytics class supports.  At the moment it only supports
 * one, but interfaces are built so that it can accommodate new ones if we ever
 * switch, making it relatively trivial to do so.
 */
typedef NS_ENUM(NSUInteger, SENAnalyticsProviderName) {
    SENAnalyticsProviderNameAmplitude
};

@interface SENAnalytics : NSObject

/**
 * @method
 * Configure this class to use the provider specified by name, using the properties
 * passed in, which should include the kSENAnalyticsConfigAPIKey.
 *
 * @param provider:   the name of the provider to configure to
 * @param properties: a dictionary of properties the provider should use, which
 *                    should include at least the API key as all providers require it
 */
+ (void)configure:(SENAnalyticsProviderName)provider with:(NSDictionary*)properties;

/*
 * @method
 * Set the user id of the currently authorized user of the application so that all
 * events can be properly mapped
 *
 * @param userId:     the unique identifier of the user of the application
 * @param properties: any particular information about the user that should be tracked
 */
+ (void)setUserId:(NSString*)userId properties:(NSDictionary*)properties;

/**
 * @method
 * Track the event by name.  This simply calls track:properties: with no properties
 *
 * @param eventName: the name of the event to use
 *
 * @see track:properties:
 */
+ (void)track:(NSString*)eventName;

/**
 * @method
 * Track the event by name, providing optionak key/value pairs to attach to the
 * event for further details
 * 
 * @param eventName:  the name of the event to use
 * @param properties: the details to add to the event
 */
+ (void)track:(NSString*)eventName properties:(NSDictionary*)properties;

/**
 * @method
 * Track the error encountered by specifying the name to use as the event.  This
 * is a convenience method to track:properties where the code and message of the
 * error will be automaticaly logged as the event's properties.
 *
 * @param error:     the error to track
 * @param eventName: the name to use for the error
 */
+ (void)trackError:(NSError*)error withEventName:(NSString*)eventName;

@end
