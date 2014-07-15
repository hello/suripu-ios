
#import "HEMSensor.h"
#import "HEMKeyedArchiver.h"

NSString* const HEMSensorUpdatedNotification = @"HEMSensorUpdatedNotification";

static NSString* const HEMSensorArchiveKey = @"Sensors";
static NSString* const HEMSensorNameKey = @"name";
static NSString* const HEMSensorValueKey = @"value";
static NSString* const HEMSensorMessageKey = @"message";
static NSString* const HEMSensorConditionKey = @"condition";
static NSString* const HEMSensorLastUpdatedKey = @"last_updated";
static NSString* const HEMSensorUnitKey = @"unit";

@implementation HEMSensor

+ (NSArray*)sensors
{
    return [[HEMKeyedArchiver objectsForKey:HEMSensorArchiveKey] allObjects];
}

+ (NSString*)formatValue:(NSNumber*)value withUnit:(HEMSensorUnit)unit
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

+ (NSString*)localizedStringPrefixForUnit:(HEMSensorUnit)unit
{
    switch (unit) {
    case HEMSensorUnitDegreeCentigrade:
        return @"measurement.temperature.";

    case HEMSensorUnitPartsPerMillion:
        return @"measurement.ppm.";

    case HEMSensorUnitPercent:
        return @"measurement.percentage.";

    default:
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _name = dict[HEMSensorNameKey];
        _value = dict[HEMSensorValueKey];
        _message = dict[HEMSensorMessageKey];
        _condition = [HEMSensor conditionFromValue:dict[HEMSensorConditionKey]];
        _unit = [HEMSensor unitFromValue:dict[HEMSensorUnitKey]];
        _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dict[HEMSensorLastUpdatedKey] doubleValue]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:HEMSensorNameKey];
        _value = [aDecoder decodeObjectForKey:HEMSensorValueKey];
        _message = [aDecoder decodeObjectForKey:HEMSensorMessageKey];
        _condition = [[aDecoder decodeObjectForKey:HEMSensorConditionKey] integerValue];
        _unit = [[aDecoder decodeObjectForKey:HEMSensorUnitKey] integerValue];
        _lastUpdated = [aDecoder decodeObjectForKey:HEMSensorLastUpdatedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.name forKey:HEMSensorNameKey];
    [aCoder encodeObject:self.value forKey:HEMSensorValueKey];
    [aCoder encodeObject:self.message forKey:HEMSensorMessageKey];
    [aCoder encodeObject:@(self.condition) forKey:HEMSensorConditionKey];
    [aCoder encodeObject:@(self.unit) forKey:HEMSensorUnitKey];
    [aCoder encodeObject:self.lastUpdated forKey:HEMSensorLastUpdatedKey];
}

- (NSUInteger)hash
{
    return self.name.hash;
}

- (BOOL)isEqual:(HEMSensor*)sensor
{
    if (![sensor isKindOfClass:[HEMSensor class]])
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
    return  prefix ? NSLocalizedString(localizationKey, nil): @"";
}

- (void)save
{
    [HEMKeyedArchiver addObject:self toObjectsForKey:HEMSensorArchiveKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:HEMSensorUpdatedNotification object:self];
}

#pragma mark formatting

+ (HEMSensorUnit)unitFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"CENTIGRADE"])
            return HEMSensorUnitDegreeCentigrade;
        else if ([value isEqualToString:@"PPM"])
            return HEMSensorUnitPartsPerMillion;
        else if ([value isEqualToString:@"PERCENT"])
            return HEMSensorUnitPercent;
    } else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return HEMSensorUnitUnknown;
}

+ (HEMSensorCondition)conditionFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        if ([value isEqualToString:@"ALERT"])
            return HEMSensorConditionAlert;
        else if ([value isEqualToString:@"WARNING"])
            return HEMSensorConditionWarning;
        else if ([value isEqualToString:@"IDEAL"])
            return HEMSensorConditionIdeal;
    } else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return HEMSensorConditionUnknown;
}

@end
