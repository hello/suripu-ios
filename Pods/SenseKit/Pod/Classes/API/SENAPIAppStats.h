//
//  SENAPIAppStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <UIKit/UIKit.h>
#import "SENAPIClient.h"

@class SENAppStats;

@interface SENAPIAppStats : NSObject

/**
 * Retrieve the application stats.
 *
 * @param completion: block to invoke upon completion of the request.  If the
 *                    request was successful, the data returned with be a SENAppStats
 *                    object.  Otherwise, an error is returned
 */
+ (void)stats:(nonnull SENAPIDataBlock)completion;

/**
 * Update the appplication stats given the object that represents the changes.
 * Only the changes provided will be updated.
 *
 * @param stats:      a SENAppStats object that contain the changes / updates
 * @param completion: the block to invoke upon completion, containing an Error
 *                    object if the request failed.  Data returned can be ignored
 */
+ (void)updateStats:(nonnull SENAppStats*)stats completion:(nonnull SENAPIDataBlock)completion;

/**
 * Retrieve the unread flags for the application indicating areas of the application
 * that contain new, unseen, items.
 *
 * @param completion: block to invoke upon completion of the request.  If the
 *                    request was successful, the data returned with be a SENAppUnreadStats
 *                    object.  Otherwise, an error is returned
 */
+ (void)unread:(nonnull SENAPIDataBlock)completion;

@end
