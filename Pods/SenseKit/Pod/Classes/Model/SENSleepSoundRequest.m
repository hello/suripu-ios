//
//  SENSleepSoundRequest.m
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import "SENSleepSoundRequest.h"
#import "Model.h"

@interface SENSleepSoundRequest()

@property (nonatomic, strong) NSNumber* order;

@end

@implementation SENSleepSoundRequest

static NSString* const SleepSoundRequestOrder = @"order";

- (instancetype)init {
    self = [super init];
    if (self) {
        _order = SENDateMillisecondsSince1970([NSDate date]);
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{SleepSoundRequestOrder : [self order]};
}

@end

@implementation SENSleepSoundRequestStop
// nothing different than the base request model, for now
@end

@interface SENSleepSoundRequestPlay()

@property (nonatomic, strong) NSNumber* soundId;
@property (nonatomic, strong) NSNumber* durationId;
@property (nonatomic, strong) NSNumber* volume; // between 0 - 100

@end

@implementation SENSleepSoundRequestPlay

static NSString* const SENSleepSoundRequestPlayParamSound = @"sound";
static NSString* const SENSleepSoundRequestPlayParamDuration = @"duration";
static NSString* const SENSleepSoundRequestPlayParamVolume = @"volume_percent";

- (instancetype)initWithSoundId:(NSNumber*)soundId
                     durationId:(NSNumber*)durationId
                         volume:(NSNumber*)volume {
    self = [super init];
    if (self) {
        _soundId = soundId;
        _durationId = durationId;
        _volume = volume;
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    NSMutableDictionary* value = [[super dictionaryValue] mutableCopy];
    value[SENSleepSoundRequestPlayParamSound] = [self soundId];
    value[SENSleepSoundRequestPlayParamDuration] = [self durationId];
    value[SENSleepSoundRequestPlayParamVolume] = [self volume];
    return value;
}

@end
