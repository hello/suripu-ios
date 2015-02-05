//
//  SENPreference.m
//  Pods
//
//  Created by Jimmy Lu on 1/15/15.
//
//

#import "SENPreference.h"

NSString* const SENPreferenceNameEnhancedAudio = @"ENHANCED_AUDIO";
NSString* const SENPreferenceNameTemp = @"TEMP_CELCIUS";
NSString* const SENPreferenceNameTime = @"TIME_TWENTY_FOUR_HOUR";
NSString* const SENPreferenceNamePushScore = @"PUSH_SCORE";
NSString* const SENPreferenceNamePushConditions = @"PUSH_ALERT_CONDITIONS";

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
             SENPreferenceEnable : @([self isEnabled])};
}

@end
