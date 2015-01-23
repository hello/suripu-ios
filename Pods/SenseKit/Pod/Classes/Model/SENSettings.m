
#import "SENSettings.h"

NSString* const SENSettingsAppGroup = @"group.is.hello.sense.settings";
NSString* const SENSettingsTimeFormat = @"SENSettingsTimeFormat";
NSString* const SENSettingsTemperatureFormat = @"SENSettingsTemperatureFormat";
NSString* const SENSettingsDidUpdateNotification = @"SENSettingsDidUpdateNotification";
NSString* const SENSettingsUpdateTypeTime = @"time";
NSString* const SENSettingsUpdateTypeTemp = @"temp";

/**
 * TODO (jimmy): we should see if we can somehow merge this with account preferences
 * @see SENServiceAccount
 */
@implementation SENSettings

+ (NSUserDefaults*)userDefaults {
    static NSUserDefaults* defaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    });
    return defaults;
}

+ (SENTimeFormat)timeFormat
{
    NSInteger timeFormat = [[self userDefaults] integerForKey:SENSettingsTimeFormat];
    if (timeFormat == 0) {
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            timeFormat = SENTimeFormat12Hour;
        } else {
            timeFormat = SENTimeFormat24Hour;
        }
        [[self userDefaults] setInteger:timeFormat forKey:SENSettingsTimeFormat];
    }
    return timeFormat;
}

+ (SENTemperatureFormat)temperatureFormat
{
    NSInteger tempFormat = [[self userDefaults] integerForKey:SENSettingsTemperatureFormat];
    if (tempFormat == 0) {
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            tempFormat = SENTemperatureFormatFahrenheit;
        } else {
            tempFormat = SENTemperatureFormatCentigrade;
        }
        [[self userDefaults] setInteger:tempFormat forKey:SENSettingsTemperatureFormat];
    }
    return tempFormat;
}

+ (BOOL)useCentigrade
{
    return [self temperatureFormat] == SENTemperatureFormatCentigrade;
}

+ (void)setTemperatureFormat:(SENTemperatureFormat)temperatureFormat
{
    [[self userDefaults] setInteger:temperatureFormat forKey:SENSettingsTemperatureFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSettingsDidUpdateNotification
                                                        object:SENSettingsUpdateTypeTemp];
}

+ (void)setTimeFormat:(SENTimeFormat)timeFormat
{
    [[self userDefaults] setInteger:timeFormat forKey:SENSettingsTimeFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSettingsDidUpdateNotification
                                                        object:SENSettingsUpdateTypeTime];
}

+ (NSDictionary*)defaults {
    return @{SENSettingsTimeFormat : @([self timeFormat]),
             SENSettingsTemperatureFormat : @([self temperatureFormat])};
}

@end
