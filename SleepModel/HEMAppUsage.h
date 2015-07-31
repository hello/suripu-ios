//
//  HEMAppUsage.h
//  Sense
//
//  Use this class to keep track of activities that occur within the app such as
//
//      1. How many times have user taken the action in the last 7 days
//      2. How long ago did the activity last was triggered?
//
//  Created by Jimmy Lu on 7/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const HEMAppUsageSystemAlertShown;
extern NSString* const HEMAppUsageAppLaunched;
extern NSString* const HEMAppUsageTimelineShownWithData;
extern NSString* const HEMAppUsageAppReviewPromptCompleted;

typedef NS_ENUM(NSUInteger, HEMAppUsageInterval) {
    HEMAppUsageIntervalLast7Days,
    HEMAppUsageIntervalLast31Days
};

@interface HEMAppUsage : NSObject <NSCoding>

@property (nonatomic, copy,   readonly) NSString* identifier;
@property (nonatomic, strong, readonly) NSDate* created;
@property (nonatomic, strong, readonly) NSDate* updated;

/**
 * @method appUsageForIdentifier:
 *
 * @discussion
 * Retrieve the app usage for the specified identifier.  If nothing was ever saved
 * before, a new object is created and returned
 *
 * @param identifier: the unique identifier of the usage
 * @return            app usage object
 */
+ (HEMAppUsage*)appUsageForIdentifier:(NSString *)identifier;

/**
 * @method incrementUsageForIdentifier:
 *
 * @discussion
 * Convenience method to retrieve (or create) an app usage instance, increment
 * the value by 1 and automatically saving it after
 *
 * @param identifier: the unique identifier of the usage
 * @return            app usage object
 */
+ (void)incrementUsageForIdentifier:(NSString *)identifier;

/**
 * @method increment:
 *
 * @discussion
 * Increment the usage by 1 and optionally auto persist the change
 */
- (void)increment:(BOOL)autosave;

/**
 * @method save
 *
 * @discussion
 * Save the object.  This is needed if @method increment: was called without
 * autosave.
 */
- (void)save;

/**
 * @method usageWithin:
 *
 * @discussion:
 * Return the usage count within the interval specified
 *
 * @param interval: the time within which to check usage
 * @return          number greater or equal to 0 that indicates the usage
 */
- (NSUInteger)usageWithin:(HEMAppUsageInterval)interval;

@end
