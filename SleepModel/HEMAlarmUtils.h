
#import <Foundation/Foundation.h>

@class SENAlarm, HEMAlarmCache;

extern NSUInteger const HEMAlarmTooSoonMinuteLimit;

@interface HEMAlarmUtils : NSObject

/**
 *  Check for whether a time is too soon for setting an alarm
 *
 *  @param hour   hour to validate
 *  @param minute minute to validate
 *
 *  @return YES if the time is too soon
 */
+ (BOOL)timeIsTooSoonByHour:(NSUInteger)hour minute:(NSUInteger)minute;

/**
 *  Text representing the repeat settings of an alarm
 *
 *  @param alarmRepeatFlags repeat flags property of an alarm
 *
 *  @return localized repeat settings text
 */
+ (NSString*)repeatTextForUnitFlags:(NSUInteger)alarmRepeatFlags;

/**
 *  Upload changes to alarms to server
 *
 *  @param controller presenting controller
 *  @param completion block invoked at completion
 */
+ (void)updateAlarmsFromPresentingController:(UIViewController*)controller
                                  completion:(void (^)(NSError *error))completion;

/**
 *  Download latest alarm data from server
 *
 *  @param controller presenting controller
 *  @param completion block invoked at completion
 */
+ (void)refreshAlarmsFromPresentingController:(UIViewController*)controller
                                   completion:(void (^)(NSError*))completion;

+ (BOOL)areRepeatDaysValid:(SENAlarmRepeatDays)repeatDays
             forSmartAlarm:(SENAlarm*)alarm presentingControllerForErrors:(UIViewController*)controller;

@end
