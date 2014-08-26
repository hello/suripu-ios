
#import <Foundation/Foundation.h>

struct SENAlarmTime {
    NSInteger hour;
    NSInteger minute;
};

@interface SENAlarm : NSObject <NSCoding>

/**
 *  A persisted alarms
 *
 *  @return the alarm
 */
+ (SENAlarm*)savedAlarm;

/**
 *  Remove all cached alarm data
 */
+ (void)clearSavedAlarms;

/**
 *  Presents a time in a locale-specific representation
 *
 *  @param time the time to format
 *
 *  @return a string representing the time
 */
+ (NSString*)localizedValueForTime:(struct SENAlarmTime)time;

/**
 *  Creates a new alarm from a dictionary of property values
 *
 *  @param dict property values with keys corresponding to a translation map
 *
 *  @return a new alarm or nil
 */
- (instancetype)initWithDictionary:(NSDictionary*)dict;

/**
 *  Change the time of an alarm by a specified number of minutes. Use of a
 *  negative number sets the time earlier.
 *
 *  @param minutes number of minutes by which the alarm is incremented
 */
- (void)incrementAlarmTimeByMinutes:(NSInteger)minutes;

/**
 *  Calculates the time when a specified number of minutes are added.
 *
 *  @param minutes number of minutes to add
 *
 *  @return a structure representing an alarm time
 */
- (struct SENAlarmTime)timeByAddingMinutes:(NSInteger)minutes;

/**
 *  Persists the alarm
 */
- (void)save;

/**
 *  Presents the alarm time in a locale-specific representation
 *
 *  @return a string representing the alarm wake time
 */
- (NSString*)localizedValue;

@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic) NSInteger hour;
@property (nonatomic) NSInteger minute;
@property (nonatomic, copy) NSString* soundName;
@end
