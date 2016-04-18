//
//  SENSleepSoundStatus.m
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import "SENSleepSoundStatus.h"
#import "Model.h"

static NSString* const SENSleepSoundStatusParamPlaying = @"playing";
static NSString* const SENSleepSoundStatusParamSound = @"sound";
static NSString* const SENSleepSoundStatusParamDuration = @"duration";
static NSString* const SENSLeepSoundStatusParamVolume = @"volume_percent";

@interface SENSleepSoundStatus()

@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, strong) SENSleepSound* sound;
@property (nonatomic, strong) SENSleepSoundDuration* duration;
@property (nonatomic, strong) NSNumber* volume;

@end

@implementation SENSleepSoundStatus

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _playing = SENBoolValue(dictionary[SENSleepSoundStatusParamPlaying]);
        
        NSDictionary* rawSound = SENObjectOfClass(dictionary[SENSleepSoundStatusParamSound], [NSDictionary class]);
        if (rawSound) {
            _sound = [[SENSleepSound alloc] initWithDictionary:rawSound];
        }
        
        NSDictionary* rawDuration = SENObjectOfClass(dictionary[SENSleepSoundStatusParamDuration], [NSDictionary class]);
        if (rawDuration) {
            _duration = [[SENSleepSoundDuration alloc] initWithDictionary:rawDuration];
        }
        
        _volume = SENObjectOfClass(dictionary[SENSLeepSoundStatusParamVolume], [NSNumber class]);
    }
    return self;
}

@end
