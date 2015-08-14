//
//  SENPreference.m
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import "SENPreference.h"
#import "SENLocalPreferences.h"

NSString* const SENPreferenceNameEnhancedAudio = @"ENHANCED_AUDIO";
NSString* const SENPreferenceNameTemp = @"TEMP_CELSIUS";
NSString* const SENPreferenceNameTime = @"TIME_TWENTY_FOUR_HOUR";
NSString* const SENPreferenceNamePushScore = @"PUSH_SCORE";
NSString* const SENPreferenceNamePushConditions = @"PUSH_ALERT_CONDITIONS";
NSString* const SENPreferenceNameHeightMetric = @"HEIGHT_METRIC";
NSString* const SENPreferenceNameWeightMetric = @"WEIGHT_METRIC";

@interface SENPreference()

@property (nonatomic, assign, readwrite) SENPreferenceType type;

@end

@implementation SENPreference

static NSString* const SENPreferenceName = @"pref";
static NSString* const SENPreferenceEnable = @"enabled";

+ (SENPreferenceType)typeFromName:(id)nameObject {
    SENPreferenceType type = SENPreferenceTypeUnknown;
    NSString* uppercaseName
        = [nameObject isKindOfClass:[NSString class]]
        ? [nameObject uppercaseString]
        : nil;
    if ([uppercaseName isEqualToString:SENPreferenceNameEnhancedAudio]) {
        type = SENPreferenceTypeEnhancedAudio;
    } else if ([uppercaseName isEqualToString:SENPreferenceNameTemp]) {
        type = SENPreferenceTypeTempCelcius;
    } else if ([uppercaseName isEqualToString:SENPreferenceNameTime]) {
        type = SENPreferenceTypeTime24;
    } else if ([uppercaseName isEqualToString:SENPreferenceNamePushConditions]) {
        type = SENPreferenceTypePushConditions;
    } else if ([uppercaseName isEqualToString:SENPreferenceNamePushScore]) {
        type = SENPreferenceTypePushScore;
    } else if ([uppercaseName isEqualToString:SENPreferenceNameHeightMetric]) {
        type = SENPreferenceTypeHeightMetric;
    } else if ([uppercaseName isEqualToString:SENPreferenceNameWeightMetric]) {
        type = SENPreferenceTypeWeightMetric;
    }
    return type;
}

+ (NSString*)nameFromType:(SENPreferenceType)type {
    switch (type) {
        case SENPreferenceTypeEnhancedAudio:
            return SENPreferenceNameEnhancedAudio;
        case SENPreferenceTypeTempCelcius:
            return SENPreferenceNameTemp;
        case SENPreferenceTypeTime24:
            return SENPreferenceNameTime;
        case SENPreferenceTypePushScore:
            return SENPreferenceNamePushScore;
        case SENPreferenceTypePushConditions:
            return SENPreferenceNamePushConditions;
        default:
            return @"";
    }
}

+ (SENTimeFormat)timeFormat {
    SENLocalPreferences* pref = [SENLocalPreferences sharedPreferences];
    NSNumber* enabled = [pref userPreferenceForKey:SENPreferenceNameTime];
    SENTimeFormat timeFormat;
    if (enabled == nil) {
        BOOL militaryTimeEnabled = NO;
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            timeFormat = SENTimeFormat12Hour;
        } else {
            timeFormat = SENTimeFormat24Hour;
            militaryTimeEnabled = YES;
        }
        [pref setUserPreference:@(militaryTimeEnabled) forKey:SENPreferenceNameTime];
    } else {
        timeFormat = [enabled boolValue] ? SENTimeFormat24Hour : SENTimeFormat12Hour;
    }
    return timeFormat;
}

+ (SENTemperatureFormat)temperatureFormat {
    SENLocalPreferences* pref = [SENLocalPreferences sharedPreferences];
    NSNumber* enabled = [pref userPreferenceForKey:SENPreferenceNameTemp];
    SENTemperatureFormat tempFormat;
    if (enabled == nil) {
        BOOL celsiusEnabled = NO;
        if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_US"]) {
            tempFormat = SENTemperatureFormatFahrenheit;
        } else {
            tempFormat = SENTemperatureFormatCentigrade;
            celsiusEnabled = YES;
        }
        [pref setUserPreference:@(celsiusEnabled) forKey:SENPreferenceNameTemp];
    } else {
        tempFormat = [enabled boolValue] ? SENTemperatureFormatCentigrade : SENTemperatureFormatFahrenheit;
    }
    return tempFormat;
}

+ (BOOL)useMetricUnitForHeight {
    SENLocalPreferences* pref = [SENLocalPreferences sharedPreferences];
    NSNumber* enabled = [pref userPreferenceForKey:SENPreferenceNameHeightMetric];
    if (enabled == nil) {
        BOOL usesMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        [pref setUserPreference:@(usesMetric) forKey:SENPreferenceNameHeightMetric];
        return usesMetric;
    }
    return [enabled boolValue];
}

+ (BOOL)useMetricUnitForWeight {
    SENLocalPreferences* pref = [SENLocalPreferences sharedPreferences];
    NSNumber* enabled = [pref userPreferenceForKey:SENPreferenceNameWeightMetric];
    if (enabled == nil) {
        BOOL usesMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        [pref setUserPreference:@(usesMetric) forKey:SENPreferenceNameWeightMetric];
        return usesMetric;
    }
    return [enabled boolValue];
}

+ (BOOL)useCentigrade {
    return [self temperatureFormat] == SENTemperatureFormatCentigrade;
}

- (instancetype)initWithType:(SENPreferenceType)type enable:(BOOL)enable {
    self = [super init];
    if (self) {
        _type = type;
        _enabled = enable;
    }
    return self;
}

- (instancetype)initWithName:(NSString*)name value:(NSNumber*)value {
    SENPreferenceType type = [SENPreference typeFromName:name];
    if (type == SENPreferenceTypeUnknown) return nil;
    return [self initWithType:type enable:[value boolValue]];
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (dictionary == nil) return nil;
    
    SENPreferenceType type = [SENPreference typeFromName:dictionary[SENPreferenceName]];
    BOOL enabled
        = [dictionary[SENPreferenceEnable] isKindOfClass:[NSNumber class]]
        ? [dictionary[SENPreferenceEnable] boolValue]
        : NO;
    return [self initWithType:type enable:enabled];
}

- (void)saveLocally {
    SENLocalPreferences* pref = [SENLocalPreferences sharedPreferences];
    [pref setUserPreference:@([self isEnabled]) forKey:[[self class] nameFromType:[self type]]];
}

- (NSDictionary*)dictionaryValue {
    return @{SENPreferenceName : [[self class] nameFromType:[self type]],
             SENPreferenceEnable : @([self isEnabled])};
}

@end
