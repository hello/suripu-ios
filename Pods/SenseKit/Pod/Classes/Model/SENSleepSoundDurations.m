//
//  SENSleepSoundDurations.m
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import "SENSleepSoundDurations.h"
#import "Model.h"

@interface SENSleepSoundDuration()

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, copy) NSString* localizedName;

@end

@implementation SENSleepSoundDuration

static NSString* const SleepSoundDurationParamId = @"id";
static NSString* const SleepSoundDurationParamName = @"name";

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _identifier = SENObjectOfClass(dictionary[SleepSoundDurationParamId], [NSNumber class]);
        _localizedName = [SENObjectOfClass(dictionary[SleepSoundDurationParamName], [NSString class]) copy];
    }
    return self;
}

@end

@interface SENSleepSoundDurations()

@property (nonatomic, strong) NSArray<SENSleepSoundDuration*>* durations;

@end

@implementation SENSleepSoundDurations

static NSString* const SleepSoundDurationsParamDurations = @"durations";

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        NSArray* rawDurations = SENObjectOfClass(dictionary[SleepSoundDurationsParamDurations],
                                                 [NSArray class]);
        _durations = [self parseRawDurations:rawDurations];
    }
    return self;
}

- (NSArray<SENSleepSoundDuration*>*)parseRawDurations:(NSArray*)rawDurations {
    NSMutableArray<SENSleepSoundDuration*>* durations = [NSMutableArray arrayWithCapacity:[rawDurations count]];
    for (id object in rawDurations) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [durations addObject:[[SENSleepSoundDuration alloc] initWithDictionary:object]];
        }
    }
    return durations;
}
                                                  
@end
