//
//  SENSleepSoundsState.m
//  Pods
//
//  Created by Jimmy Lu on 4/6/16.
//
//

#import "Model.h"
#import "SENSleepSoundsState.h"

static NSString* const SENSleepSoundStatePropSounds = @"availableSounds";
static NSString* const SENSleepSoundStatePropDurations = @"availableDurations";
static NSString* const SENSleepSoundStatePropStatus = @"status";

@interface SENSleepSoundsState()

@property (nonatomic, strong) SENSleepSounds* sounds;
@property (nonatomic, strong) SENSleepSoundDurations* durations;
@property (nonatomic, strong) SENSleepSoundStatus* status;

@end

@implementation SENSleepSoundsState

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        id rawObj = dictionary[SENSleepSoundStatePropSounds];
        NSDictionary* rawDict = SENObjectOfClass(rawObj, [NSDictionary class]);
        _sounds = [[SENSleepSounds alloc] initWithDictionary:rawDict];
        
        rawObj = dictionary[SENSleepSoundStatePropDurations];
        rawDict = SENObjectOfClass(rawObj, [NSDictionary class]);
        _durations = [[SENSleepSoundDurations alloc] initWithDictionary:rawDict];
        
        rawObj = dictionary[SENSleepSoundStatePropStatus];
        rawDict = SENObjectOfClass(rawObj, [NSDictionary class]);
        _status = [[SENSleepSoundStatus alloc] initWithDictionary:rawDict];
    }
    return self;
}

@end
