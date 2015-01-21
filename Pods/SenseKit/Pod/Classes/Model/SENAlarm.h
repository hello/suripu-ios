
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
 *  The next date and time at which this alarm will fire
 *
 *  @return a date
 */
- (NSDate*)nextRingDate;

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

/**
 *  Check whether the alarm has ever been persisted
 *
 *  @return YES if an alarm with a matching identifier is present in the data store
 */
- (BOOL)isSaved;

/**
 *  Compares alarm property values
 *
 *  @param alarm another alarm
 *
 *  @return YES if the alarms have the same properties
 */
- (BOOL)isIdenticalToAlarm:(SENAlarm*)alarm;

/**
 * Check whether the alarm is being repeated on any day
 *
 * @return YES if this alarm will sound more than once
 */
- (BOOL)isRepeated;

/**
 * Check whether the alarm is being repeated on specific days
 *
 * @return YES if this alarm will sound on any of the selected days
 */
- (BOOL)isRepeatedOn:(SENAlarmRepeatDays)days;

@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic, readonly, getter=isEditable) BOOL editable;
@property (nonatomic, getter=isSmartAlarm) BOOL smartAlarm;
@property (nonatomic) NSUInteger hour;
@property (nonatomic) NSUInteger minute;
@property (nonatomic) NSUInteger repeatFlags;
@property (nonatomic, copy) NSString* soundName;
@property (nonatomic, strong) NSString* soundID;
@end
