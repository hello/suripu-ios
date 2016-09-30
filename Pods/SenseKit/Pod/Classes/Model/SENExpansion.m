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
static NSString* const kSENExpansionAttrIcon = @"icon";
static NSString* const kSENExpansionAttrAuthUri = @"auth_uri";
static NSString* const kSENExpansionAttrCompletionUri = @"completion_uri";
static NSString* const kSENExpansionAttrState = @"state";
static NSString* const kSENExpansionAttrDescription = @"description";

static NSString* const kSENExpansionStateEnumNotConnected = @"NOT_CONNECTED";
static NSString* const kSENExpansionStateEnumConnectedOn = @"CONNECTED_ON";
static NSString* const kSENExpansionStateEnumConnectedOff = @"CONNECTED_OFF";
static NSString* const kSENExpansionStateEnumRevoked = @"REVOKED";
static NSString* const kSENExpansionStateEnumNotConfigured = @"NOT_CONFIGURED";

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        _identifier = SENObjectOfClass(dict[kSENExpansionAttrId], [NSString class]);
        _category = SENObjectOfClass(dict[kSENExpansionAttrCategory], [NSString class]);
        _deviceName = SENObjectOfClass(dict[kSENExpansionAttrDeviceName], [NSString class]);
        _serviceName = SENObjectOfClass(dict[kSENExpansionAttrServiceName], [NSString class]);
        _authUri = SENObjectOfClass(dict[kSENExpansionAttrAuthUri], [NSString class]);
        _authCompletionUri = SENObjectOfClass(dict[kSENExpansionAttrCompletionUri], [NSString class]);
        _expansionDescription = SENObjectOfClass(dict[kSENExpansionAttrDescription], [NSString class]);
 
        NSDictionary* iconDict = SENObjectOfClass(dict[kSENExpansionAttrIcon], [NSDictionary class]);
        _remoteIcon = [[SENRemoteImage alloc] initWithDictionary:iconDict];
        
        NSString* stateText = SENObjectOfClass(dict[kSENExpansionAttrState], [NSString class]);
        _state = [self stateFromString:stateText];
    }
    return self;
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
        && SENObjectIsEqual([self category], [other category])
        && SENObjectIsEqual([self deviceName], [other deviceName])
        && SENObjectIsEqual([self serviceName], [other serviceName])
        && SENObjectIsEqual([self authUri], [other authUri])
        && SENObjectIsEqual([self authCompletionUri], [other authCompletionUri])
        && [self state] == [other state];
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
static NSString* const  kSENExpansionConfigAttrName = @"name";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _identifier = SENObjectOfClass(data[kSENExpansionConfigAttrId], [NSString class]);
        _localizedName = SENObjectOfClass(data[kSENExpansionConfigAttrName], [NSString class]);
    }
    return self;
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
        && SENObjectIsEqual([self localizedName], [other localizedName]);
}

- (NSDictionary*)dictionaryValue {
    return @{kSENExpansionConfigAttrId : [self identifier],
             kSENExpansionConfigAttrName : [self localizedName]};
}

@end
