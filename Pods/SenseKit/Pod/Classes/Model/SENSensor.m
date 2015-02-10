
#import "SENAPIRoom.h"
#import "SENSensor.h"
#import "SENKeyedArchiver.h"
#import "SENSettings.h"

NSString* const SENSensorUpdatedNotification = @"SENSensorUpdatedNotification";
NSString* const SENSensorsUpdatedNotification = @"SENSensorsUpdatedNotification";
NSString* const SENSensorUpdateFailedNotification = @"SENSensorUpdateFailedNotification";
NSInteger const SENSensorSentinelValue = -1;

@implementation SENSensorDataPoint

static NSString* const SENSensorDataPointValueKey = @"value";
static NSString* const SENSensorDataPointDateKey = @"datetime";
static NSString* const SENSensorDataPointDateOffsetKey = @"offset_millis";

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        NSNumber* value = dict[SENSensorDataPointValueKey];
        _value = [value floatValue] == SENSensorSentinelValue ? nil : value;
        _dateOffset = dict[SENSensorDataPointDateOffsetKey];
        _date = [NSDate dateWithTimeIntervalSince1970:([dict[SENSensorDataPointDateKey] doubleValue])/1000];
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.value hash] + [self.date hash] + [self.dateOffset hash];
}

- (BOOL)isEqual:(SENSensorDataPoint*)object
{
    if (![object isKindOfClass:[SENSensorDataPoint class]])
        return NO;
    return ((self.value && [self.value isEqual:object.value]) || (!self.value && !object.value))
        && ((self.date && [self.date isEqualToDate:object.date]) || (!self.date && !object.date))
        && ((self.dateOffset && [self.dateOffset isEqualToNumber:object.dateOffset]) || (!self.dateOffset && !object.dateOffset));
}

- (NSString *)description
{
    static NSString* const SENSensorDataPointDescriptionFormat =  @"<SENSensorDataPoint @date=%@ @value=%@>";
    return [NSString stringWithFormat:SENSensorDataPointDescriptionFormat, self.date, self.value];
}

@end

@implementation SENSensor

static NSString* const SENSensorArchiveKey = @"Sensors";
static NSString* const SENSensorNameKey = @"name";
static NSString* const SENSensorValueKey = @"value";
static NSString* const SENSensorMessageKey = @"message";
static NSString* const SENSensorConditionKey = @"condition";
static NSString* const SENSensorLastUpdatedKey = @"last_updated_utc";
static NSString* const SENSensorIdealMessageKey = @"ideal_conditions";
static NSString* const SENSensorUnitKey = @"unit";

static NSString* const SENSensorUnitCentigradeSymbol = @"c";
static NSString* const SENSensorUnitAQISymbol = @"AQI";
static NSString* const SENSensorUnitPercentSymbol = @"%";
static NSString* const SENSensorUnitLuxSymbol = @"lux";
static NSString* const SENSensorUnitDecibelSymbol = @"dB";
static NSString* const SENSensorConditionIdealSymbol = @"IDEAL";
static NSString* const SENSensorConditionAlertSymbol = @"ALERT";
static NSString* const SENSensorConditionWarningSymbol = @"WARNING";

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
    
    double formattedValue = (unit == SENSensorUnitDegreeCentigrade)
                            ? [self temperatureValueInPreferredUnit:[value doubleValue]]
                            : [value doubleValue];

    NSString* prefix = [self localizedStringPrefixForUnit:unit];
    NSString* format;
    if (prefix) {
        NSString* localizationKey = [NSString stringWithFormat:@"%@format", prefix];
        format = NSLocalizedString(localizationKey, nil);
    }
    else {
        format = @"%.0f";
    }

    return [NSString stringWithFormat:format, formattedValue];
}

+ (NSNumber*)value:(NSNumber*)value inPreferredUnit:(SENSensorUnit)unit
{
    if (unit == SENSensorUnitDegreeCentigrade) {
        return @([SENSensor temperatureValueInPreferredUnit:[value doubleValue]]);
    }
    return value;
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

    case SENSensorUnitAQI:
        return @"measurement.particle.";

    case SENSensorUnitPercent:
        return @"measurement.percentage.";

    case SENSensorUnitDecibel:
        return @"measurement.sound.";

    case SENSensorUnitLux:
        return @"measurement.light.";

    default:
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _name = dict[SENSensorNameKey];
        NSNumber* value = dict[SENSensorValueKey];
        _value = [value floatValue] == SENSensorSentinelValue ? nil : value;
        _message = dict[SENSensorMessageKey];
        _idealConditionsMessage = dict[SENSensorIdealMessageKey];
        _condition = [SENSensor conditionFromValue:dict[SENSensorConditionKey]];
        _unit = [SENSensor unitFromValue:dict[SENSensorUnitKey]];
        _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dict[SENSensorLastUpdatedKey] doubleValue] / 1000];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:SENSensorNameKey];
        _value = [aDecoder decodeObjectForKey:SENSensorValueKey];
        _message = [aDecoder decodeObjectForKey:SENSensorMessageKey];
        _idealConditionsMessage = [aDecoder decodeObjectForKey:SENSensorIdealMessageKey];
        _condition = [[aDecoder decodeObjectForKey:SENSensorConditionKey] integerValue];
        _unit = [[aDecoder decodeObjectForKey:SENSensorUnitKey] integerValue];
        _lastUpdated = [aDecoder decodeObjectForKey:SENSensorLastUpdatedKey];
    }
    return self;
}

- (NSString *)description
{
    static NSString* const SENSensorDescriptionFormat =  @"<SENSensor @name=%@ @value=%@ @lastUpdated=%@>";
    return [NSString stringWithFormat:SENSensorDescriptionFormat, self.name, self.value, self.lastUpdated];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_name forKey:SENSensorNameKey];
    [aCoder encodeObject:_value forKey:SENSensorValueKey];
    [aCoder encodeObject:_message forKey:SENSensorMessageKey];
    [aCoder encodeObject:@(_condition) forKey:SENSensorConditionKey];
    [aCoder encodeObject:@(_unit) forKey:SENSensorUnitKey];
    [aCoder encodeObject:_lastUpdated forKey:SENSensorLastUpdatedKey];
    [aCoder encodeObject:_idealConditionsMessage forKey:SENSensorIdealMessageKey];
}

- (NSNumber*)valueInPreferredUnit
{
    return [[self class] value:self.value inPreferredUnit:self.unit];
}

- (NSUInteger)hash
{
    return self.name.hash + self.value.hash;
}

- (BOOL)isEqual:(SENSensor*)sensor
{
    if (![sensor isKindOfClass:[SENSensor class]])
        return NO;

    return ((self.name && [self.name isEqualToString:sensor.name]) || (!self.name && !sensor.name))
        && ((self.value && [self.value isEqual:sensor.value]) || (!self.value && !sensor.value))
        && ((self.message && [self.message isEqual:sensor.message]) || (!self.message && !sensor.message))
        && ((self.idealConditionsMessage && [self.idealConditionsMessage isEqualToString:sensor.idealConditionsMessage])
            || (!self.idealConditionsMessage && !sensor.idealConditionsMessage))
        && self.condition == sensor.condition
        && self.unit == sensor.unit;
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
        if ([value isEqualToString:SENSensorUnitCentigradeSymbol])
            return SENSensorUnitDegreeCentigrade;
        else if ([value isEqualToString:SENSensorUnitAQISymbol])
            return SENSensorUnitAQI;
        else if ([value isEqualToString:SENSensorUnitPercentSymbol])
            return SENSensorUnitPercent;
        else if ([value isEqualToString:SENSensorUnitLuxSymbol])
            return SENSensorUnitLux;
        else if ([value isEqualToString:SENSensorUnitDecibelSymbol])
            return SENSensorUnitDecibel;
    }
    else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return SENSensorUnitUnknown;
}

+ (SENSensorCondition)conditionFromValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        NSString* normalizedValue = [(NSString*)value uppercaseString];
        if ([normalizedValue isEqualToString:SENSensorConditionAlertSymbol])
            return SENSensorConditionAlert;
        else if ([normalizedValue isEqualToString:SENSensorConditionWarningSymbol])
            return SENSensorConditionWarning;
        else if ([normalizedValue isEqualToString:SENSensorConditionIdealSymbol])
            return SENSensorConditionIdeal;
    }
    else if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return SENSensorConditionUnknown;
}

@end
