
#import <Foundation/Foundation.h>

struct HEMAlarmTime {
    NSInteger hour;
    NSInteger minute;
};

@interface HEMAlarm : NSObject <NSCoding>

/**
 *  An array of all persisted alarms
 *
 *  @return the array
 */
+ (HEMAlarm*)savedAlarm;

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
- (struct HEMAlarmTime)timeByAddingMinutes:(NSInteger)minutes;

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
