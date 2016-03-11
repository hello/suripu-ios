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

@interface SENSleepSoundStatus()

@property (nonatomic, assign, getter=isPlaying) BOOL playing;
@property (nonatomic, strong) SENSleepSound* sound;
@property (nonatomic, strong) SENSleepSoundDuration* duration;

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
    }
    return self;
}

@end
