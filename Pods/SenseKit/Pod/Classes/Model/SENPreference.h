//
//  SENPreference.h
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENPreferenceType) {
    SENPreferenceTypeUnknown = 0,
    /**
     *  Enable support for enhanced audio processing
     */
    SENPreferenceTypeEnhancedAudio = 1,
    /**
     *  Represent time in 24-hour format
     */
    SENPreferenceTypeTime24 = 2,
    /**
     *  Represent temperature values in Celcius
     */
    SENPreferenceTypeTempCelcius = 3,
    /**
     *  Receive push notifications for score in the morning
     */
    SENPreferenceTypePushScore = 4,
    /**
     *  Receive push notifications for poor sleep environment in the evening
     */
    SENPreferenceTypePushConditions = 5,
};

/**
 *  Possible values for a temperature format
 */
typedef NS_ENUM(NSUInteger, SENTemperatureFormat) {
    /**
     *  The sensible default for most of the world
     */
    SENTemperatureFormatCentigrade = 1,
    /**
     *  Something for the USA
     */
    SENTemperatureFormatFahrenheit = 2,
};

/**
 *  Possible values for a clock format
 */
typedef NS_ENUM(NSUInteger, SENTimeFormat) {
    /**
     *  A 24-hour clock
     */
    SENTimeFormat24Hour = 1,
    /**
     *  12-hour clock, using meridien
     */
    SENTimeFormat12Hour = 2,
};

extern NSString* const SENPreferenceNameEnhancedAudio;
extern NSString* const SENPreferenceNameTemp;
extern NSString* const SENPreferenceNameTime;
extern NSString* const SENPreferenceNamePushScore;
extern NSString* const SENPreferenceNamePushConditions;

@interface SENPreference : NSObject

@property (nonatomic, assign, readonly) SENPreferenceType type;
@property (nonatomic, assign, readwrite, getter = isEnabled) BOOL enabled;

/**
 * @param type: the type of the preference
 * @return name: the name of the preference used by the api
 */
+ (NSString*)nameFromType:(SENPreferenceType)type;

/**
 *  The preferred clock format. If none specified, defaults to something
 *  sensible based on the current locale.
 *
 *  @return the clock format to use
 */
+ (SENTimeFormat)timeFormat;

/**
 *  The preferred temperature format. If none specified, defaults to
 *  whatever the current locale probably prefers.
 *
 *  @return the temperature format to use
 */
+ (SENTemperatureFormat)temperatureFormat;

/**
 *  Convenience method for obtaining the temperature format.
 *
 *  @return YES if the temperature format represents centigrade
 */
+ (BOOL)useCentigrade;

/**
 * @method initWithType:enable
 *
 * @param type: the type of the prefence
 * @param enable: YES to enable, NO otherwise
 * @return initialized instance with the given type and enable flag
 */
- (instancetype)initWithType:(SENPreferenceType)type enable:(BOOL)enable;

/**
 * @method initWithName:value
 *
 * @param name: the server dictated name of the preference
 * @param value: a number object that determines the enable state of the pref
 * @return initialized instance, if name is specified and recognized
 */
- (instancetype)initWithName:(NSString*)name value:(NSNumber*)value;

/**
 * @method initWithDictionary:
 *
 * @param dictionary: a raw json-to-dictionary representation of a preference
 * @return initialized instance
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

/**
 * @method dictionaryValue
 * @return a dictionary representation of the instance that would be identical
 *         a dictionary that would be used to initialize an instace
 *
 * @see @method initWithDictionary:
 */
- (NSDictionary*)dictionaryValue;

/**
 * Save the preference locally, using the type's name value as the key and the 
 * value being YES or NO for enabled or not
 */
- (void)saveLocally;

@end
