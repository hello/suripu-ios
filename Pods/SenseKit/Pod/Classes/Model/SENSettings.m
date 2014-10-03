
#import "SENSettings.h"

NSString* const SENSettingsTimeFormat = @"SENSettingsTimeFormat";
NSString* const SENSettingsTemperatureFormat = @"SENSettingsTemperatureFormat";
NSString* const SENSettingsDidUpdateNotification = @"SENSettingsDidUpdateNotification";

@implementation SENSettings

+ (SENTimeFormat)timeFormat
{
    NSInteger timeFormat = [[NSUserDefaults standardUserDefaults] integerForKey:SENSettingsTimeFormat];
    if (timeFormat == 0) {
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            timeFormat = SENTimeFormat12Hour;
        } else {
            timeFormat = SENTimeFormat24Hour;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:timeFormat forKey:SENSettingsTimeFormat];
    }
    return timeFormat;
}

+ (SENTemperatureFormat)temperatureFormat
{
    NSInteger tempFormat = [[NSUserDefaults standardUserDefaults] integerForKey:SENSettingsTemperatureFormat];
    if (tempFormat == 0) {
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            tempFormat = SENTemperatureFormatFahrenheit;
        } else {
            tempFormat = SENTemperatureFormatCentigrade;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:tempFormat forKey:SENSettingsTemperatureFormat];
    }
    return tempFormat;
}

+ (void)setTemperatureFormat:(SENTemperatureFormat)temperatureFormat
{
    [[NSUserDefaults standardUserDefaults] setInteger:temperatureFormat forKey:SENSettingsTemperatureFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSettingsDidUpdateNotification object:nil];
}

+ (void)setTimeFormat:(SENTimeFormat)timeFormat
{
    [[NSUserDefaults standardUserDefaults] setInteger:timeFormat forKey:SENSettingsTimeFormat];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSettingsDidUpdateNotification object:nil];
}

+ (NSDictionary*)defaults {
    return @{SENSettingsTimeFormat : @([self timeFormat]),
             SENSettingsTemperatureFormat : @([self temperatureFormat])};
}

@end
