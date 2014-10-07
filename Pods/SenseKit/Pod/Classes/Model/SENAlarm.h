
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENAlarmRepeatDays) {
    SENAlarmRepeatSunday = (1UL << 1),
    SENAlarmRepeatMonday = (1UL << 2),
    SENAlarmRepeatTuesday = (1UL << 3),
    SENAlarmRepeatWednesday = (1UL << 4),
    SENAlarmRepeatThursday = (1UL << 5),
    SENAlarmRepeatFriday = (1UL << 6),
    SENAlarmRepeatSaturday = (1UL << 7),
};

struct SENAlarmTime {
    NSInteger hour;
    NSInteger minute;
};

@interface SENAlarm : NSObject <NSCoding>

/**
 *  Cached alarm
 *
 *  @return the alarms
 */
+ (NSArray*)savedAlarms;

/**
 *  Create a new alarm using the default settings
 *
 *  @return an alarm
 */
+ (SENAlarm*)createDefaultAlarm;

+ (struct SENAlarmTime)time:(struct SENAlarmTime)initialTime byAddingMinutes:(NSInteger)minutes;

/**
 *  Remove all cached alarms
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
 *  Removes the alarm from the persistent store
 */
- (void)delete;

/**
 *  Presents the alarm time in a locale-specific representation
 *
 *  @return a string representing the alarm wake time
 */
- (NSString*)localizedValue;

@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic, readonly, getter=isEditable) BOOL editable;
@property (nonatomic, getter=isSmartAlarm) BOOL smartAlarm;
@property (nonatomic) NSUInteger hour;
@property (nonatomic) NSUInteger minute;
@property (nonatomic) NSUInteger repeatFlags;
@property (nonatomic, copy) NSString* soundName;
@end
