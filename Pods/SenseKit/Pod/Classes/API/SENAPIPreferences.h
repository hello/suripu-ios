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
 * Update a particular preference for the currently signed in account
 * @param preference: preference to be updated
 * @param completion:
 */
+ (void)updatePreference:(SENPreference*)preference completion:(SENAPIDataBlock)completion;

@end
