
#import <Foundation/Foundation.h>

/**
 *  Notification sent when a sensor value is saved
 */
extern NSString* const SENSensorUpdatedNotification;

/**
 *  Notification sent when all sensors have been updated
 */
extern NSString* const SENSensorsUpdatedNotification;

/**
 *  Notification sent when a sensor update fails
 */
extern NSString* const SENSensorUpdateFailedNotification;

typedef NS_ENUM(NSUInteger, SENSensorCondition) {
    SENSensorConditionUnknown,
    SENSensorConditionAlert,
    SENSensorConditionIdeal,
    SENSensorConditionWarning,
};

typedef NS_ENUM(NSUInteger, SENSensorUnit) {
    SENSensorUnitUnknown,
    SENSensorUnitDegreeCentigrade,
    SENSensorUnitAQI,
    SENSensorUnitPercent,
};

@interface SENSensor : NSObject <NSCoding>

/**
 *  Known persisted sensors
 *
 *  @return Array of SENSensor objects
 */
+ (NSArray*)sensors;

/**
 *  Remove all cached sensor data
 */
+ (void)clearCachedSensors;

/**
 *  Sends a request to the API for the latest environmental sensor values and
 *  updates the cache
 */
+ (void)refreshCachedSensors;

/**
 *  Creates a localized string from a given value and unit
 *
 *  @param value numeric value to format
 *  @param unit  measurement unit of the value
 *
 *  @return a localized string
 */
+ (NSString*)formatValue:(NSNumber*)value withUnit:(SENSensorUnit)unit;

/**
 *  Creates a localized value from a given value and unit
 *
 *  @param value numeric value to format
 *  @param unit  measurement unit of the value
 *
 *  @return number formatted according to the unit
 */
+ (NSNumber*)value:(NSNumber*)value inPreferredUnit:(SENSensorUnit)unit;

/**
 *  Discovers the unit for a particular string value
 *
 *  @param value a unit format string, like 'ppm' or 'c'
 *
 *  @return the matching unit or SENSensorUnitUnknown
 */
+ (SENSensorUnit)unitFromValue:(id)value;

/**
 *  Identifies a matching sensor condition from a value
 * 
 *  @param value a condition format string, like 'ALERT'
 *
 *  @return the matching condition or SENSensorConditionUnknown
 */
+ (SENSensorCondition)conditionFromValue:(id)value;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

/**
 *  A localized version of the quantified value
 *
 *  @return the localized string
 */
- (NSString*)localizedValue;

/**
 *  The value translated into the user's preferred unit
 *
 *  @return the value
 */
- (NSNumber*)valueInPreferredUnit;

/**
 *  A localized version of the unit
 *
 *  @return the localized string
 */
- (NSString*)localizedUnit;

/**
 *  A localized version of the persisted name property
 *
 *  @return the localized string
 */
- (NSString*)localizedName;

/**
 *  Writes a sensor to the persisted store
 */
- (void)save;

@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* message;
@property (nonatomic, strong, readonly) NSString* idealConditionsMessage;
@property (nonatomic, strong, readonly) NSDate* lastUpdated;
@property (nonatomic, readonly) NSNumber* value;
@property (nonatomic, readonly) SENSensorCondition condition;
@property (nonatomic, readonly) SENSensorUnit unit;
@end

@interface SENSensorDataPoint : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, strong, readonly) NSNumber* value;
@property (nonatomic, strong, readonly) NSNumber* dateOffset;
@end
