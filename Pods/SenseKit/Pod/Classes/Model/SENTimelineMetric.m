//
//  SENTimelineMetric.m
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import "SENTimelineMetric.h"
#import "Model.h"

SENTimelineMetricType SENTimelineMetricTypeFromString(NSString* metricType) {
    if ([metricType isKindOfClass:[NSString class]]) {
        if ([metricType isEqualToString:@"total_sleep"])
            return SENTimelineMetricTypeTotalDuration;
        else if ([metricType isEqualToString:@"sound_sleep"])
            return SENTimelineMetricTypeSoundDuration;
        else if ([metricType isEqualToString:@"time_to_sleep"])
            return SENTimelineMetricTypeTimeToSleep;
        else if ([metricType isEqualToString:@"times_awake"])
            return SENTimelineMetricTypeTimesAwake;
        else if ([metricType isEqualToString:@"fell_asleep"])
            return SENTimelineMetricTypeFellAsleep;
        else if ([metricType isEqualToString:@"woke_up"])
            return SENTimelineMetricTypeWokeUp;
        else if ([metricType isEqualToString:@"temperature"])
            return SENTimelineMetricTypeTemperature;
        else if ([metricType isEqualToString:@"humidity"])
            return SENTimelineMetricTypeHumidity;
        else if ([metricType isEqualToString:@"light"])
            return SENTimelineMetricTypeLight;
        else if ([metricType isEqualToString:@"sound"])
            return SENTimelineMetricTypeSound;
        else if ([metricType isEqualToString:@"particulates"])
            return SENTimelineMetricTypeParticulates;
    }
    return SENTimelineMetricTypeUnknown;
}
SENTimelineMetricUnit SENTimelineMetricUnitFromString(NSString* metricUnit) {
    if ([metricUnit isKindOfClass:[NSString class]]) {
        if ([metricUnit isEqualToString:@"MINUTES"])
            return SENTimelineMetricUnitMinute;
        else if ([metricUnit isEqualToString:@"QUANTITY"])
            return SENTimelineMetricUnitQuantity;
        else if ([metricUnit isEqualToString:@"TIMESTAMP"])
            return SENTimelineMetricUnitTimestamp;
        else if ([metricUnit isEqualToString:@"CONDITION"])
            return SENTimelineMetricUnitCondition;
    }
    return SENTimelineMetricUnitUnknown;
}

@implementation SENTimelineMetric

static NSString* const SENTimelineMetricNameKey = @"name";
static NSString* const SENTimelineMetricValueKey = @"value";
static NSString* const SENTimelineMetricUnitKey = @"unit";
static NSString* const SENTimelineMetricTypeKey = @"type";
static NSString* const SENTimelineMetricConditionKey = @"condition";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _name = SENObjectOfClass(data[SENTimelineMetricNameKey], [NSString class]);
        _value = SENObjectOfClass(data[SENTimelineMetricValueKey], [NSNumber class]);
        _unit = SENTimelineMetricUnitFromString(data[SENTimelineMetricUnitKey]);
        _condition = SENConditionFromString(data[SENTimelineMetricConditionKey]);
        _type = SENTimelineMetricTypeFromString(data[SENTimelineMetricNameKey]);
    }
    return self;
}

- (BOOL)updateWithDictionary:(NSDictionary *)data {
    BOOL changed = NO;
    changed = [self updateWithName:data[SENTimelineMetricNameKey]];
    if ([data[SENTimelineMetricValueKey] isKindOfClass:[NSNumber class]]
        && ![self.value isEqualToNumber:data[SENTimelineMetricValueKey]]) {
        self.value = data[SENTimelineMetricValueKey];
        changed = YES;
    }
    if (data[SENTimelineMetricUnitKey]) {
        SENTimelineMetricUnit unit = SENTimelineMetricUnitFromString(data[SENTimelineMetricUnitKey]);
        if (unit != self.unit) {
            self.unit = unit;
            changed = YES;
        }
    }
    if (data[SENTimelineMetricConditionKey]) {
        SENCondition condition = SENConditionFromString(data[SENTimelineMetricConditionKey]);
        if (condition != self.condition) {
            self.condition = condition;
            changed = YES;
        }
    }
    return changed;
}

- (BOOL)updateWithName:(NSString*)name {
    if ([name isKindOfClass:[NSString class]]) {
        if (![self.name isEqualToString:name]) {
            self.name = name;
            self.type = SENTimelineMetricTypeFromString(name);
            return YES;
        }
    }
    return NO;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENTimelineMetricNameKey];
        _value = [aDecoder decodeObjectForKey:SENTimelineMetricValueKey];
        _unit = [aDecoder decodeIntegerForKey:SENTimelineMetricUnitKey];
        _type = [aDecoder decodeIntegerForKey:SENTimelineMetricTypeKey];
        _condition = [aDecoder decodeIntegerForKey:SENTimelineMetricConditionKey];
    }
    return self;
}

- (NSString*)description {
    static NSString* const SENTimelineMetricDescriptionFormat = @"<SENTimelineMetric @name=%@ @value=%@>";
    return [NSString stringWithFormat:SENTimelineMetricDescriptionFormat, self.name, self.value];
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:self.name forKey:SENTimelineMetricNameKey];
    [aCoder encodeObject:self.value forKey:SENTimelineMetricValueKey];
    [aCoder encodeInteger:self.type forKey:SENTimelineMetricTypeKey];
    [aCoder encodeInteger:self.condition forKey:SENTimelineMetricConditionKey];
    [aCoder encodeInteger:self.unit forKey:SENTimelineMetricUnitKey];
}

- (BOOL)isEqual:(SENTimelineMetric*)object {
    if (![object isKindOfClass:[SENTimelineMetric class]])
        return NO;
    return ((self.name && [self.name isEqual:object.name]) || (!self.name && !object.name))
        && ((self.value && [self.value isEqual:object.value]) || (!self.value && !object.value))
        && self.type == object.type
        && self.condition == object.condition
        && self.unit == object.unit;
}

- (NSUInteger)hash {
    return [self.name hash] + [self.value hash] + self.type;
}

@end