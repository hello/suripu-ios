
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSUInteger, SENAPIAlarmsRepeatDay) {
    SENAPIAlarmsRepeatDayMonday = 1,
    SENAPIAlarmsRepeatDayTuesday = 2,
    SENAPIAlarmsRepeatDayWednesday = 3,
    SENAPIAlarmsRepeatDayThursday = 4,
    SENAPIAlarmsRepeatDayFriday = 5,
    SENAPIAlarmsRepeatDaySaturday = 6,
    SENAPIAlarmsRepeatDaySunday = 7,
};

@interface SENAPIAlarms : NSObject

/**
 *  Fetch stored alarms
 *
 *  @param completion block invoked when call completes asynchronously,
 *                    with the data parameter set to returned alarm data
 */
+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion;

/**
 *  Update stored alarms
 *
 *  @param alarms     an array of SENAlarm objects
 *  @param completion block invoked when call completes asynchronously
 *                    with the data parameter set to returned alarm data
 */
+ (void)updateAlarms:(NSArray*)alarms completion:(SENAPIDataBlock)completion;

@end
