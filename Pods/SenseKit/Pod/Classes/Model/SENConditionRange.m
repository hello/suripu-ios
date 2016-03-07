//
//  SENConditionRange.m
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//
#import "Model.h"
#import "SENConditionRange.h"

static NSString* const SENConditionRangeMinValue = @"min_value";
static NSString* const SENConditionRangeMaxValue = @"max_value";
static NSString* const SENConditionRangeCondition = @"condition";

@interface SENConditionRange()

@property (nonatomic, strong) NSNumber* minValue;
@property (nonatomic, strong) NSNumber* maxValue;
@property (nonatomic, assign) SENCondition condition;

@end

@implementation SENConditionRange

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _minValue = SENObjectOfClass(dictionary[SENConditionRangeMinValue], [NSNumber class]);
        _maxValue = SENObjectOfClass(dictionary[SENConditionRangeMaxValue], [NSNumber class]);
        _condition = SENConditionFromString(dictionary[SENConditionRangeCondition]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENConditionRange class]]) {
        return NO;
    }
    
    SENConditionRange* other = object;
    return [[self minValue] isEqual:[other minValue]]
        && [[self maxValue] isEqual:[other maxValue]]
        && [self condition] == [other condition];
}

- (NSUInteger)hash {
    NSUInteger const prime = 31;
    NSUInteger result = prime + [[self maxValue] hash];
    result = prime * result + [[self minValue] hash];
    return prime * result + [self condition];
}

@end
