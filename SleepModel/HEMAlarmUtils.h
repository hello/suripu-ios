
#import <Foundation/Foundation.h>

@class SENAlarm, HEMAlarmCache;

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
 *  Checks whether repeating days are in use by an enabled smart alarm
 *
 *  @param days          days of week
 *  @param excludedAlarm an alarm to allow to use a particular day
 *
 *  @return YES if the day is in use by an alarm other than excludedAlarm
 */
+ (BOOL)daysInUse:(SENAlarmRepeatDays)day excludingAlarm:(SENAlarm*)excludedAlarm;


+ (SENAlarmRepeatDays)repeatDaysForAlarmCache:(HEMAlarmCache*)alarm;

+ (SENAlarmRepeatDays)repeatDaysForAlarm:(SENAlarm*)alarm;

+ (BOOL)areRepeatDaysValid:(SENAlarmRepeatDays)repeatDays
             forSmartAlarm:(SENAlarm*)alarm presentingControllerForErrors:(UIViewController*)controller;
@end
