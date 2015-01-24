//
//  SENPreference.m
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import "SENPreference.h"

static NSString* const SENPreferenceName = @"pref";
static NSString* const SENPreferenceNameEnhancedAudio = @"ENHANCED_AUDIO";
static NSString* const SENPreferenceNameTemp = @"TEMP_CELCIUS";
static NSString* const SENPreferenceNameTime = @"TIME_TWENTY_FOUR_HOUR";
static NSString* const SENPreferenceEnable = @"enabled";

@interface SENPreference()

@property (nonatomic, assign, readwrite) SENPreferenceType type;

@end

@implementation SENPreference

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
    }
    return type;
}

+ (NSString*)nameFromType:(SENPreferenceType)type {
    NSString* name = @""; // should not return nil
    switch (type) {
        case SENPreferenceTypeEnhancedAudio:
            name = SENPreferenceNameEnhancedAudio;
            break;
        case SENPreferenceTypeTempCelcius:
            name = SENPreferenceNameTemp;
            break;
        case SENPreferenceTypeTime24:
            name = SENPreferenceNameTime;
            break;
        default:
            break;
    }
    return name;
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

- (NSDictionary*)dictionaryValue {
    return @{SENPreferenceName : [[self class] nameFromType:[self type]],
             SENPreferenceEnable : @([self enabled])};
}

@end
