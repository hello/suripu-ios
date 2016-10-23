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
        _primaryUser = SENObjectOfClass(data[SENSenseVoiceDictPropPrmaryUser], [NSNumber class]);
        _muted = SENObjectOfClass(data[SENSenseVoiceDictPropMuted], [NSNumber class]);
    }
    return self;
}

- (BOOL)isPrimaryUser {
    return [[self primaryUser] boolValue];
}

- (BOOL)isMuted {
    return [[self muted] boolValue];
}

- (NSDictionary*)dictionaryValue {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity:3];
    if ([self primaryUser]) {
        [data setObject:[self primaryUser] forKey:SENSenseVoiceDictPropPrmaryUser];
    }
    if ([self muted]) {
        [data setObject:[self muted] forKey:SENSenseVoiceDictPropMuted];
    }
    if ([self volume]) {
        [data setObject:[self volume] forKey:SENSenseVoiceDictPropVolume];
    }
    return data;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSenseVoiceSettings* other = object;
    return SENObjectIsEqual([self volume], [other volume])
        && SENObjectIsEqual([self primaryUser], [other primaryUser])
        && SENObjectIsEqual([self muted], [other muted]);
}

- (NSUInteger)hash {
    return [[self volume] hash] + [self isPrimaryUser] + [self isMuted];
}

@end
