//
//  SENSenseVoiceSettings.m
//  Pods
//
//  Created by Jimmy Lu on 10/19/16.
//
//

#import "SENSenseVoiceSettings.h"
#import "Model.h"

@implementation SENSenseVoiceSettings

static NSString* const SENSenseVoiceDictPropPrmaryUser = @"is_primary_user";
static NSString* const SENSenseVoiceDictPropVolume = @"volume";
static NSString* const SENSenseVoiceDictPropMuted = @"muted";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _volume = SENObjectOfClass(data[SENSenseVoiceDictPropVolume], [NSNumber class]);
        _primaryUser = [SENObjectOfClass(data[SENSenseVoiceDictPropPrmaryUser], [NSNumber class]) boolValue];
        _muted = [SENObjectOfClass(data[SENSenseVoiceDictPropMuted], [NSNumber class]) boolValue];
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{SENSenseVoiceDictPropPrmaryUser : @([self isPrimaryUser]),
             SENSenseVoiceDictPropMuted : @([self isMuted]),
             SENSenseVoiceDictPropVolume : [self volume] ?: @1};
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSenseVoiceSettings* other = object;
    return SENObjectIsEqual([self volume], [other volume])
        && [self isPrimaryUser] == [other isPrimaryUser]
        && [self isMuted] == [other isMuted];
}

- (NSUInteger)hash {
    return [[self volume] hash] + [self isPrimaryUser] + [self isMuted];
}

@end
