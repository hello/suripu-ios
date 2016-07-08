//
//  SENAPIPreferences.h
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENPreference;

@interface SENAPIPreferences : NSObject

/**
 *  Update preferences remotely, invoking a callback at completion
 *
 *  @param completion block invoked when asynchronous call completes
 */
+ (void)updatePreferencesWithCompletion:(SENAPIDataBlock)completion;

/**
 * Retrieve the preferences from the API in the form of a dictionary such that
 *
 *      key:    preference type as a NSNumber
 *      value:  SENPreference object
 *
 * @param completion: the block to invoke when preferences are returned
 */
+ (void)getPreferences:(SENAPIDataBlock)completion;

@end
