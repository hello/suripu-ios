
#import "SENAPIRoom.h"
#import "SENSensor.h"
#import "SENKeyedArchiver.h"
#import "SENSettings.h"

NSString* const SENSensorUpdatedNotification = @"SENSensorUpdatedNotification";
NSString* const SENSensorsUpdatedNotification = @"SENSensorsUpdatedNotification";
NSString* const SENSensorUpdateFailedNotification = @"SENSensorUpdateFailedNotification";

NSString* const SENSensorArchiveKey = @"Sensors";
NSString* const SENSensorNameKey = @"name";
NSString* const SENSensorValueKey = @"value";
NSString* const SENSensorMessageKey = @"message";
NSString* const SENSensorConditionKey = @"condition";
NSString* const SENSensorLastUpdatedKey = @"last_updated_utc";
NSString* const SENSensorUnitKey = @"unit";

@implementation SENSensor

+ (NSArray*)sensors
{
    return [SENKeyedArchiver allObjectsInCollection:NSStringFromClass([self class])];
}

+ (void)clearCachedSensors
{
    [SENKeyedArchiver removeAllObjectsInCollection:NSStringFromClass([self class])];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSensorsUpdatedNotification object:nil];
}

+ (void)refreshCachedSensors
{
    [SENAPIRoom currentWithCompletion:^(NSDictionary* data, NSError* error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SENSensorUpdateFailedNotification object:nil];
            return;
        }
        NSMutableArray* sensors = [[NSMutableArray alloc] initWithCapacity:[data count]];
        [data enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL *stop) {
            NSMutableDictionary* values = [obj mutableCopy];
            values[SENSensorNameKey] = key;
            SENSensor* sensor = [[SENSensor alloc] initWithDictionary:values];
            if (sensor) {
                [sensors addObject:sensor];
                [sensor save];
            }
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:SENSensorsUpdatedNotification object:sensors];
    }];
}

+ (NSString*)formatValue:(NSNumber*)value withUnit:(SENSensorUnit)unit
{
    if (!value || [value isEqual:[NSNull null]])
        return nil;

    NSString* prefix = [self localizedStringPrefixForUnit:unit];
    NSString* format;
    if (prefix) {
        NSString* localizationKey = [NSString stringWithFormat:@"%@format", prefix];
        format = NSLocalizedString(localizationKey, nil);
    } else {
        format = @"%.0f";
    }

    double formattedValue = (unit == SENSensorUnitDegreeCentigrade)
                                ? [self temperatureValueInPreferredUnit:[value doubleValue]]
                                : [value doubleValue];
    return [NSString stringWithFormat:format, formattedValue];
}

+ (double)temperatureValueInPreferredUnit:(double)value
{
    if ([SENSettings temperatureFormat] == SENTemperatureFormatFahrenheit) {
        return (value * 1.8) + 32;
    }
    return value;
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
        _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dict[SENSensorLastUpdatedKey] floatValue] / 1000];
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
    [aCoder encodeObject:_name forKey:SENSensorNameKey];
    [aCoder encodeObject:_value forKey:SENSensorValueKey];
    [aCoder encodeObject:_message forKey:SENSensorMessageKey];
    [aCoder encodeObject:@(_condition) forKey:SENSensorConditionKey];
    [aCoder encodeObject:@(_unit) forKey:SENSensorUnitKey];
    [aCoder encodeObject:_lastUpdated forKey:SENSensorLastUpdatedKey];
}

- (NSNumber*)valueInPreferredUnit
{
    if (self.unit == SENSensorUnitDegreeCentigrade) {
        return @([SENSensor temperatureValueInPreferredUnit:[self.value doubleValue]]);
    }
    return self.value;
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
    [SENKeyedArchiver setObject:self forKey:self.name inCollection:NSStringFromClass([SENSensor class])];
    [[NSNotificationCenter defaultCenter] postNotificationName:SENSensorUpdatedNotification object:self];
}

#pragma mark formatting

+ (SENSensorUnit)unitFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"c"])
            return SENSensorUnitDegreeCentigrade;
        else if ([value isEqualToString:@"ppm"])
            return SENSensorUnitPartsPerMillion;
        else if ([value isEqualToString:@"%"])
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
