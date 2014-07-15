
#import "SENSensor.h"
#import "SENKeyedArchiver.h"

NSString* const SENSensorUpdatedNotification = @"SENSensorUpdatedNotification";

NSString* const SENSensorArchiveKey = @"Sensors";
NSString* const SENSensorNameKey = @"name";
NSString* const SENSensorValueKey = @"value";
NSString* const SENSensorMessageKey = @"message";
NSString* const SENSensorConditionKey = @"condition";
NSString* const SENSensorLastUpdatedKey = @"last_updated";
NSString* const SENSensorUnitKey = @"unit";

@implementation SENSensor

+ (NSArray*)sensors
{
    return [[SENKeyedArchiver objectsForKey:SENSensorArchiveKey] allObjects];
}

+ (NSString*)formatValue:(NSNumber*)value withUnit:(SENSensorUnit)unit
{
    NSString* prefix = [self localizedStringPrefixForUnit:unit];
    NSString* format;
    if (prefix) {
        NSString* localizationKey = [NSString stringWithFormat:@"%@format", prefix];
        format = NSLocalizedString(localizationKey, nil);
    } else {
        format = @"%@";
    }
    return [NSString stringWithFormat:format, [value doubleValue]];
}

+ (NSString*)localizedStringPrefixForUnit:(SENSensorUnit)unit
{
    switch (unit) {
    case SENSensorUnitDegreeCentigrade:
        return @"measurement.temperature.";

    case SENSensorUnitPartsPerMillion:
        return @"measurement.ppm.";

    case SENSensorUnitPercent:
        return @"measurement.percentage.";

    default:
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _name = dict[SENSensorNameKey];
        _value = dict[SENSensorValueKey];
        _message = dict[SENSensorMessageKey];
        _condition = [SENSensor conditionFromValue:dict[SENSensorConditionKey]];
        _unit = [SENSensor unitFromValue:dict[SENSensorUnitKey]];
        _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dict[SENSensorLastUpdatedKey] doubleValue]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENSensorNameKey];
        _value = [aDecoder decodeObjectForKey:SENSensorValueKey];
        _message = [aDecoder decodeObjectForKey:SENSensorMessageKey];
        _condition = [[aDecoder decodeObjectForKey:SENSensorConditionKey] integerValue];
        _unit = [[aDecoder decodeObjectForKey:SENSensorUnitKey] integerValue];
        _lastUpdated = [aDecoder decodeObjectForKey:SENSensorLastUpdatedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:SENSensorNameKey];
    [aCoder encodeObject:self.value forKey:SENSensorValueKey];
    [aCoder encodeObject:self.message forKey:SENSensorMessageKey];
    [aCoder encodeObject:@(self.condition) forKey:SENSensorConditionKey];
    [aCoder encodeObject:@(self.unit) forKey:SENSensorUnitKey];
    [aCoder encodeObject:self.lastUpdated forKey:SENSensorLastUpdatedKey];
}

- (NSUInteger)hash
{
    return self.name.hash;
}

- (BOOL)isEqual:(SENSensor*)sensor
{
    if (![sensor isKindOfClass:[SENSensor class]])
        return NO;

    return [sensor.name isEqualToString:self.name];
}

- (NSString*)localizedName
{
    NSString* localizedKey = [NSString stringWithFormat:@"sensor.%@", self.name];
    NSString* localizedName = NSLocalizedString(localizedKey, nil);
    if (![localizedName isEqualToString:localizedKey])
        return localizedName;

    return [self.name capitalizedString];
}

- (NSString*)localizedValue
{
    return [[self class] formatValue:self.value withUnit:self.unit];
}

- (NSString*)localizedUnit
{
    NSString* prefix = [[self class] localizedStringPrefixForUnit:self.unit];
    NSString* localizationKey = [NSString stringWithFormat:@"%@unit", prefix];
    return prefix ? NSLocalizedString(localizationKey, nil) : @"";
}

- (void)save
{
    [SENKeyedArchiver addObject:self toObjectsForKey:SENSensorArchiveKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSensorUpdatedNotification object:self];
}

#pragma mark formatting

+ (SENSensorUnit)unitFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"CENTIGRADE"])
            return SENSensorUnitDegreeCentigrade;
        else if ([value isEqualToString:@"PPM"])
            return SENSensorUnitPartsPerMillion;
        else if ([value isEqualToString:@"PERCENT"])
            return SENSensorUnitPercent;
    } else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return SENSensorUnitUnknown;
}

+ (SENSensorCondition)conditionFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"ALERT"])
            return SENSensorConditionAlert;
        else if ([value isEqualToString:@"WARNING"])
            return SENSensorConditionWarning;
        else if ([value isEqualToString:@"IDEAL"])
            return SENSensorConditionIdeal;
    } else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return SENSensorConditionUnknown;
}

@end
