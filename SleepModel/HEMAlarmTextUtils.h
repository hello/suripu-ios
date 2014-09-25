
#import <Foundation/Foundation.h>

@class SENAlarm;

@interface HEMAlarmTextUtils : NSObject

/**
 *  Text representing the repeat settings of an alarm
 *
 *  @param alarm the alarm
 *
 *  @return localized repeat settings text
 */
+ (NSString*)repeatTextForAlarm:(SENAlarm*)alarm;

@end
