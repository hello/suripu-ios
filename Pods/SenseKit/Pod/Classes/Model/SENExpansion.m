//
//  SENExpansion.m
//  Pods
//
//  Created by Jimmy Lu on 9/27/16.
//
//

#import "SENExpansion.h"
#import "Model.h"

@implementation SENExpansion

static NSString* const kSENExpansionAttrId = @"id";
static NSString* const kSENExpansionAttrCategory = @"category";
static NSString* const kSENExpansionAttrDeviceName = @"device_name";
static NSString* const kSENExpansionAttrServiceName = @"service_name";
static NSString* const kSENExpansionAttrCompanyName = @"company_name";
static NSString* const kSENExpansionAttrIcon = @"icon";
static NSString* const kSENExpansionAttrAuthUri = @"auth_uri";
static NSString* const kSENExpansionAttrCompletionUri = @"completion_uri";
static NSString* const kSENExpansionAttrState = @"state";
static NSString* const kSENExpansionAttrDescription = @"description";
static NSString* const kSENExpansionAttrValueRange = @"value_range";

static NSString* const kSENExpansionServiceEnumHue = @"HUE";
static NSString* const kSENExpansionServiceEnumNest = @"NEST";

static NSString* const kSENExpansionStateEnumNotConnected = @"NOT_CONNECTED";
static NSString* const kSENExpansionStateEnumConnectedOn = @"CONNECTED_ON";
static NSString* const kSENExpansionStateEnumConnectedOff = @"CONNECTED_OFF";
static NSString* const kSENExpansionStateEnumRevoked = @"REVOKED";
static NSString* const kSENExpansionStateEnumNotConfigured = @"NOT_CONFIGURED";
static NSString* const kSENExpansionStateEnumNotAvailable = @"NOT_AVAILABLE";

static NSString* const kSENExpansionCategoryEnumLights = @"LIGHT";
static NSString* const kSENExpansionCategoryEnumTemp = @"TEMPERATURE";

static NSString* const kSENExpansionValueRangeAttrMin = @"min";
static NSString* const kSENExpansionValueRangeAttrMax = @"max";
static NSString* const kSENExpansionValueRangeAttrSetpoint = @"setpoint";

+ (SENExpansionType)typeFromString:(NSString*)typeString {
    NSString* upperString = [typeString uppercaseString];
    if ([upperString isEqualToString:kSENExpansionCategoryEnumLights]) {
        return SENExpansionTypeLights;
    } else if ([upperString isEqualToString:kSENExpansionCategoryEnumTemp]) {
        return SENExpansionTypeThermostat;
    } else {
        return SENExpansionTypeUnknown;
    }
}

+ (NSString*)typeStringFromEnum:(SENExpansionType)type {
    switch (type) {
        case SENExpansionTypeLights:
            return kSENExpansionCategoryEnumLights;
        case SENExpansionTypeThermostat:
            return kSENExpansionCategoryEnumTemp;
        case SENExpansionTypeUnknown:
            return @"";
    }
}

+ (SENExpansionValueRange)valueRangeFromDict:(NSDictionary*)dict {
    SENExpansionValueRange range;
    range.min = [SENObjectOfClass(dict[kSENExpansionValueRangeAttrMin], [NSNumber class]) doubleValue];
    range.max = [SENObjectOfClass(dict[kSENExpansionValueRangeAttrMax], [NSNumber class]) doubleValue];
    range.setpoint = [SENObjectOfClass(dict[kSENExpansionValueRangeAttrSetpoint], [NSNumber class]) doubleValue];
    return range;
}

+ (NSDictionary*)dictionaryValueFromRange:(SENExpansionValueRange)range {
    return @{kSENExpansionValueRangeAttrMin : @(range.min),
             kSENExpansionValueRangeAttrMax : @(range.max),
             kSENExpansionValueRangeAttrSetpoint : @(range.setpoint)};
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        _identifier = SENObjectOfClass(dict[kSENExpansionAttrId], [NSNumber class]);
        _deviceName = SENObjectOfClass(dict[kSENExpansionAttrDeviceName], [NSString class]);
        _companyName = SENObjectOfClass(dict[kSENExpansionAttrCompanyName], [NSString class]);
        _authUri = SENObjectOfClass(dict[kSENExpansionAttrAuthUri], [NSString class]);
        _authCompletionUri = SENObjectOfClass(dict[kSENExpansionAttrCompletionUri], [NSString class]);
        _expansionDescription = SENObjectOfClass(dict[kSENExpansionAttrDescription], [NSString class]);
        
        NSString* serviceName = SENObjectOfClass(dict[kSENExpansionAttrServiceName], [NSString class]);
        _service = [self serviceFromString:serviceName];
 
        NSDictionary* iconDict = SENObjectOfClass(dict[kSENExpansionAttrIcon], [NSDictionary class]);
        _remoteIcon = [[SENRemoteImage alloc] initWithDictionary:iconDict];
        
        NSString* typeText = SENObjectOfClass(dict[kSENExpansionAttrCategory], [NSString class]);
        _type = [[self class] typeFromString:typeText];
        
        NSString* stateText = SENObjectOfClass(dict[kSENExpansionAttrState], [NSString class]);
        _state = [self stateFromString:stateText];
        
        NSDictionary* range = SENObjectOfClass(dict[kSENExpansionAttrValueRange], [NSDictionary class]);
        _valueRange = [[self class] valueRangeFromDict:range];
    }
    return self;
}

- (SENExpansionService)serviceFromString:(NSString*)serviceName {
    NSString* upper = [serviceName uppercaseString];
    if ([upper isEqualToString:kSENExpansionServiceEnumHue]) {
        return SENExpansionServiceHue;
    } else if ([upper isEqualToString:kSENExpansionServiceEnumNest]) {
        return SENExpansionServiceNest;
    } else {
        return SENExpansionServiceUnknown;
    }
}

- (SENExpansionState)stateFromString:(NSString*)stateString {
    NSString* upperString = [stateString uppercaseString];
    if ([upperString isEqualToString:kSENExpansionStateEnumNotConnected]) {
        return SENExpansionStateNotConnected;
    } else if ([upperString isEqualToString:kSENExpansionStateEnumConnectedOn]) {
        return SENExpansionStateConnectedOn;
    } else if ([upperString isEqualToString:kSENExpansionStateEnumConnectedOff]) {
        return SENExpansionStateConnectedOff;
    } else if ([upperString isEqualToString:kSENExpansionStateEnumRevoked]) {
        return SENExpansionStateRevoked;
    } else if ([upperString isEqualToString:kSENExpansionStateEnumNotConfigured]) {
        return SENExpansionStateNotConfigured;
    } else if ([upperString isEqualToString:kSENExpansionStateEnumNotAvailable]) {
        return SENExpansionStateNotAvailable;
    } else {
        return SENExpansionStateUnknown;
    }
}

- (NSString*)stateStringFromEnum:(SENExpansionState)state {
    switch (state) {
        case SENExpansionStateNotConnected:
            return kSENExpansionStateEnumNotConnected;
        case SENExpansionStateConnectedOn:
            return kSENExpansionStateEnumConnectedOn;
        case SENExpansionStateConnectedOff:
            return kSENExpansionStateEnumConnectedOff;
        case SENExpansionStateRevoked:
            return kSENExpansionStateEnumRevoked;
        case SENExpansionStateNotConfigured:
            return kSENExpansionStateEnumNotConfigured;
        case SENExpansionStateNotAvailable:
            return kSENExpansionStateEnumNotAvailable;
        default:
            return @"";
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENExpansion* other = object;
    return SENObjectIsEqual([self identifier], [other identifier])
        && SENObjectIsEqual([self deviceName], [other deviceName])
        && SENObjectIsEqual([self companyName], [other companyName])
        && SENObjectIsEqual([self authUri], [other authUri])
        && SENObjectIsEqual([self authCompletionUri], [other authCompletionUri])
        && [self state] == [other state]
        && [self service] == [other service]
        && [self type] == [other type];
}

- (NSUInteger)hash {
    return [[self identifier] hash];
}

- (NSDictionary*)dictionaryValueForUpdate {
    return @{kSENExpansionAttrState : [self stateStringFromEnum:[self state]]};
}

@end

@implementation SENExpansionConfig

static NSString* const kSENExpansionConfigAttrId = @"id";
static NSString* const kSENExpansionConfigAttrName = @"name";
static NSString* const kSENExpansionConfigAttrSelected = @"selected";
static NSString* const kSENExpansionConfigAttrCapabilities = @"capabilities";
static NSString* const kSENExpansionConfigCapabilityHeat = @"HEAT";
static NSString* const kSENExpansionConfigCapabilityCool = @"COOL";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _identifier = SENObjectOfClass(data[kSENExpansionConfigAttrId],
                                       [NSString class]);
        _localizedName = SENObjectOfClass(data[kSENExpansionConfigAttrName],
                                          [NSString class]);
        _selected = [SENObjectOfClass(data[kSENExpansionConfigAttrSelected],
                                      [NSNumber class]) boolValue];
        NSArray* capabilities = SENObjectOfClass(data[kSENExpansionConfigAttrCapabilities],
                                                 [NSArray class]);
        _capabilities = [self capabilitiesFromArray:capabilities];
        
    }
    return self;
}

- (NSSet<NSNumber*>*)capabilitiesFromArray:(NSArray<NSString*>*)rawCapabilities {
    NSMutableSet<NSNumber*>* capabilities = [NSMutableSet setWithCapacity:[rawCapabilities count]];
    if (rawCapabilities) {
        for (NSString* rawCapability in rawCapabilities) {
            NSString* upper = [rawCapability uppercaseString];
            if ([upper isEqualToString:kSENExpansionConfigCapabilityHeat]) {
                [capabilities addObject:@(SENExpansionCapabilityHeat)];
            } else if ([upper isEqualToString:kSENExpansionConfigCapabilityCool]) {
                [capabilities addObject:@(SENExpansionCapabilityCool)];
            }
        }
    }
    return capabilities;
}

- (NSUInteger)hash {
    return [[self identifier] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENExpansionConfig* other = object;
    return SENObjectIsEqual([self identifier], [other identifier])
        && SENObjectIsEqual([self localizedName], [other localizedName])
        && SENObjectIsEqual([self capabilities], [other capabilities]);
}

- (NSDictionary*)dictionaryValue {
    // dictionary value used only for updates and capabilities and selected
    // flag are not needed
    return @{kSENExpansionConfigAttrId : [self identifier],
             kSENExpansionConfigAttrName : [self localizedName]};
}

- (BOOL)hasCapability:(SENExpansionCapability)capability {
    return [[self capabilities] containsObject:@(capability)];
}

@end
