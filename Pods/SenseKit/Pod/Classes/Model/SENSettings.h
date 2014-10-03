
#import <Foundation/Foundation.h>

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

/**
 *  Notification sent when settings have been updated
 */
extern NSString* const SENSettingsDidUpdateNotification;

@interface SENSettings : NSObject

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
 *  Change the preferred clock format. When the change is saved, it emits a
 *  SENSettingsDidUpdateNotification
 *
 *  @param timeFormat the clock format to use
 */
+ (void)setTimeFormat:(SENTimeFormat)timeFormat;

/**
 *  Change the preferred temperature format. When the change is saved, it
 *  emits a SENSettingsDidUpdateNotification
 *
 *  @param temperatureFormat the temperature format to use
 */
+ (void)setTemperatureFormat:(SENTemperatureFormat)temperatureFormat;

/**
 * Return defaults of the settings managed, if values have not yet been set.
 * If the values have already been set, return those.
 *
 * This can be used to register defaults for a settings bundle.
 *
 * @return dictionary containing default values
 */
+ (NSDictionary*)defaults;

@end
