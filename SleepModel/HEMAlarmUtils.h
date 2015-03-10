
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
