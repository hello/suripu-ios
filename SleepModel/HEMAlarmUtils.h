
#import <Foundation/Foundation.h>

@class SENAlarm, HEMAlarmCache;

/**
 *  The number of minutes after the current time where an
 *  alarm cannot be set due to Sense syncing limitations.
 */
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
 *  Check whether or not a given hour/minute pair will ring
 *  today when paired with a given bitmask of alarm repeat days.
 *
 *  @param hour         hour to validate.
 *  @param minute       minute to validate.
 *  @param repeatDays   repeat days of the alarm.
 *
 *  @return YES if the alarm will ring today; NO otherwise.
 */
+ (BOOL)willRingTodayWithHour:(NSUInteger)hour
                       minute:(NSUInteger)minute
                   repeatDays:(SENAlarmRepeatDays)repeatDays;

/**
 *  Convert an NSDate into an SENAlarmRepeatDays.
 *  @param date The date to convert
 *
 *  @return The repeat day corresponding to the date.
 */
+ (SENAlarmRepeatDays)alarmRepeatDayForDate:(NSDate*)date;

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
