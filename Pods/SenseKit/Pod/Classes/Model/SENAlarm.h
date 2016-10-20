
#import <Foundation/Foundation.h>
#import "SENSerializable.h"
#import "SENExpansion.h"

typedef NS_ENUM(NSUInteger, SENAlarmRepeatDays) {
    SENAlarmRepeatSunday = (1UL << 1),
    SENAlarmRepeatMonday = (1UL << 2),
    SENAlarmRepeatTuesday = (1UL << 3),
    SENAlarmRepeatWednesday = (1UL << 4),
    SENAlarmRepeatThursday = (1UL << 5),
    SENAlarmRepeatFriday = (1UL << 6),
    SENAlarmRepeatSaturday = (1UL << 7),
};

// for backward compatibility. should have used the flags to imply value
typedef NS_ENUM(NSUInteger, SENALarmRepeatDayValue) {
    SENALarmRepeatDayValueMonday = 1,
    SENALarmRepeatDayValueTuesday,
    SENALarmRepeatDayValueWednesday,
    SENALarmRepeatDayValueThursday,
    SENALarmRepeatDayValueFriday,
    SENALarmRepeatDayValueSaturday,
    SENALarmRepeatDayValueSunday,
};

typedef NS_ENUM(NSUInteger, SENALarmSource) {
    SENAlarmSourceMobile = 0,
    SENAlarmSourceVoice,
    SENAlarmSourceOther
};

struct SENAlarmTime {
    NSInteger hour;
    NSInteger minute;
};

@interface SENAlarmExpansion : NSObject <NSCoding, SENSerializable>

@property (nonatomic, strong, readonly) NSNumber* expansionId;
@property (nonatomic, assign, readonly) SENExpansionType type;
@property (nonatomic, assign) SENExpansionValueRange targetRange;
@property (nonatomic, assign, getter=isEnable) BOOL enable;

- (instancetype)initWithExpansionId:(NSNumber*)expansionId enable:(BOOL)enable;

@end

@interface SENAlarm : NSObject <NSCoding>

/**
 * Determine when the date for which the alarm should ring, given the hour and
 * minute units
 *
 * @param hour: the hour for the alarm
 * @param minute: the minute for the alarm
 * @return the next ring date
 */
+ (NSDate*)nextRingDateWithHour:(NSUInteger)hour minute:(NSUInteger)minute;

/**
 *  Create a new alarm using the default settings
 *
 *  @return an alarm
 */
+ (SENAlarm*)createDefaultAlarm;

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
 *  Presents the alarm time in a locale-specific representation
 *
 *  @return a string representing the alarm wake time
 */
- (NSString*)localizedValue;

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

/**
 * Serialize object back to raw NSDictionary, as it was received
 *
 * @return dictionary value of this object
 */
- (NSDictionary*)dictionaryValue;

/**
 * Add an expansion to the alarm
 * @param enable: YES to enable it. NO otherwise
 * @param expansionId: a valid expansion id
 */
- (void)setEnable:(BOOL)enable forExpansionId:(NSNumber*)expansionId;

@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic, readonly, assign, getter=isSaved) BOOL saved;
@property (nonatomic, readonly, assign, getter=isEditable) BOOL editable;
@property (nonatomic, getter=isSmartAlarm) BOOL smartAlarm;
@property (nonatomic, strong) NSArray<SENAlarmExpansion*>* expansions;
@property (nonatomic) NSUInteger hour;
@property (nonatomic) NSUInteger minute;
@property (nonatomic) NSUInteger repeatFlags;
@property (nonatomic, copy) NSString* soundName;
@property (nonatomic, strong) NSString* soundID;
@property (nonatomic, readonly, strong) NSString* identifier;
@property (nonatomic, readonly, assign) SENALarmSource source;

@end
