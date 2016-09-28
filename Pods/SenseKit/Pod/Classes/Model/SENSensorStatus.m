//
//  SENSensorStatus.m
//  Pods
//
//  Created by Jimmy Lu on 9/6/16.
//
//

#import "SENSensorStatus.h"
#import "Model.h"

static NSString* const kSENSensorStatusSensors = @"sensors";
static NSString* const kSENSensorStatusAttrStatus = @"status";
static NSString* const kSENSensorStatusValueOk = @"OK";
static NSString* const kSENSensorStatusValueNoSense = @"NO_SENSE";
static NSString* const kSENSensorStatusValueWaiting = @"WAITING_FOR_DATA";

@implementation SENSensorStatus

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _state = [self stateFromString:SENObjectOfClass(data[kSENSensorStatusAttrStatus], [NSString class])];
        _sensors = [self sensorsFromObject:SENObjectOfClass(data[kSENSensorStatusSensors], [NSArray class])];
    }
    return self;
}

- (SENSensorState)stateFromString:(NSString*)stateString {
    NSString* stateUpper = [stateString uppercaseString];
    if ([stateUpper isEqualToString:kSENSensorStatusValueNoSense]) {
        return SENSensorStateNoSense;
    } else if ([stateUpper isEqualToString:kSENSensorStatusValueWaiting]) {
        return SENSensorStateWaiting;
    } else if ([stateUpper isEqualToString:kSENSensorStatusValueOk]) {
        return SENSensorStateOk;
    } else {
        return SENSensorStateUnknown;
    }
}

- (NSArray<SENSensor*>*)sensorsFromObject:(NSArray*)arrayObject {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[arrayObject count]];
    NSDictionary* sensorDict = nil;
    for (id object in arrayObject) {
        sensorDict = SENObjectOfClass(object, [NSDictionary class]);
        if (sensorDict) {
            [array addObject:[[SENSensor alloc] initWithDictionary:sensorDict]];
        }
    }
    return array;
}

- (NSUInteger)hash {
    return [[self sensors] hash] + [self state];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSensorStatus* other = object;
    return SENObjectIsEqual([self sensors], [other sensors])
        && [self state] == [other state];
}

@end
