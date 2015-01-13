
#import <Foundation/Foundation.h>

@class SENAlarm;

@interface HEMAlarmUtils : NSObject

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
                                  completion:(void (^)(BOOL success))completion;

/**
 *  Download latest alarm data from server
 *
 *  @param controller presenting controller
 *  @param completion block invoked at completion
 */
+ (void)refreshAlarmsFromPresentingController:(UIViewController*)controller
                                   completion:(void (^)(NSError*))completion;

/**
 *  Checks whether a repeating day is in use for a smart alarm
 *
 *  @param day           day of week
 *  @param excludedAlarm an alarm to allow to use a particular day
 *
 *  @return YES if the day is in use by an alarm other than excludedAlarm
 */
+ (BOOL)dayInUse:(NSUInteger)day excludingAlarm:(SENAlarm*)excludedAlarm;

/**
 *  Indicates which day of the week on which a non-repeating alarm will fire
 *
 *  @param alarm non-repeating alarm
 *
 *  @return a repeat day corresponding to the weekday of the alarm
 */
+ (SENAlarmRepeatDays)fireDayForNonRepeatingAlarm:(SENAlarm*)alarm;
@end
