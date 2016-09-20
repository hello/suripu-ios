//
//  SENSensorDataRequest.m
//  Pods
//
//  Created by Jimmy Lu on 9/7/16.
//
//

#import "SENSensorDataRequest.h"
#import "Model.h"

static NSString* const kSENSensorDataRequestAttrSensors = @"sensors";
static NSString* const kSENSensorDataRequestAttrScope = @"scope";
static NSString* const kSENSensorDataRequestValueDay5Min = @"DAY_5_MINUTE";
static NSString* const kSENSensorDataRequestValueWeek1Hour = @"WEEK_1_HOUR";
static NSString* const kSENSensorDataRequestValueLast3H5Min = @"LAST_3H_5_MINUTE";

@interface SENSensorDataRequest()

@property (nonatomic, strong) NSMutableOrderedSet* sensors;
@property (nonatomic, assign) SENSensorDataScope scope;

@end

@implementation SENSensorDataRequest

- (instancetype)initWithScope:(SENSensorDataScope)scope {
    if (self = [super init]) {
        _sensors = [NSMutableOrderedSet new];
        _identifier = [NSUUID UUID];
        _scope = scope;
    }
    return self;
}

- (void)addSensor:(SENSensor*)sensor {
    NSString* type = [sensor typeStringValue];
    if (type) {
        [[self sensors] addObject:[sensor typeStringValue]];
    }
}

- (void)addSensors:(NSArray<SENSensor*>*)sensors {
    for (SENSensor* sensor in sensors) {
        [self addSensor:sensor];
    }
}

- (NSDictionary*)dictionaryValue {
    return @{kSENSensorDataRequestAttrSensors : [[self sensors] array],
             kSENSensorDataRequestAttrScope : [self scopeValueForEnum:[self scope]] };
}

- (NSString*)scopeValueForEnum:(SENSensorDataScope)scope {
    switch (scope) {
        case SENSensorDataScopeLast3H5Min:
            return kSENSensorDataRequestValueLast3H5Min;
        case SENSensorDataScopeWeek1Hour:
            return kSENSensorDataRequestValueWeek1Hour;
        case SENSensorDataScopeDay5Min:
        default:
            return kSENSensorDataRequestValueDay5Min;
    }
}

- (NSUInteger)hash {
    return [[self identifier] hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return NO;
    }
    SENSensorDataRequest* other = object;
    return SENObjectIsEqual([self identifier], [other identifier]);
}

@end
