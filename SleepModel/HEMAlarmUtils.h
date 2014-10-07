
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

+ (void)updateAlarmFromPresentingController:(UIViewController*)controller completion:(void (^)(BOOL success))completion;
@end
