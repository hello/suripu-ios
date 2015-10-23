//
//  SENSenseMetadata.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import "SENSenseMetadata.h"
#import "Model.h"

@implementation SENSenseWiFiInfo

static NSString* const SENSenseWiFiInfoDictPropSSID = @"ssid";
static NSString* const SENSenseWiFiInfoDictPropRSSI = @"rssi";
static NSString* const SENSenseWiFiInfoDictPropCondition = @"condition";
static NSString* const SENSenseWiFiInfoDictPropCondNone = @"NONE";
static NSString* const SENSenseWiFiInfoDictPropCondBad = @"BAD";
static NSString* const SENSenseWiFiInfoDictPropCondFair = @"FAIR";
static NSString* const SENSenseWiFiInfoDictPropCondGood = @"GOOD";
static NSString* const SENSenseWiFiInfoDictPropLastUpdated = @"last_updated";

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _ssid = SENObjectOfClass(dict[SENSenseWiFiInfoDictPropSSID], [NSString class]);
        _rssi = SENObjectOfClass(dict[SENSenseWiFiInfoDictPropRSSI], [NSNumber class]);
        _condition = [self conditionForValue:SENObjectOfClass(dict[SENSenseWiFiInfoDictPropCondition],
                                                              [NSString class])];
        _lastUpdated = SENDateFromNumber(dict[SENSenseWiFiInfoDictPropLastUpdated]);
    }
    return self;
}

- (SENWiFiCondition)conditionForValue:(NSString*)conditionValue {
    SENWiFiCondition condition = SENWiFiConditionNone;
    
    NSString* upperValue = [conditionValue uppercaseString];
    if ([upperValue isEqualToString:SENSenseWiFiInfoDictPropCondBad]) {
        condition = SENWiFiConditionBad;
    } else if ([upperValue isEqualToString:SENSenseWiFiInfoDictPropCondFair]) {
        condition = SENWiFiConditionFair;
    } else if ([upperValue isEqualToString:SENSenseWiFiInfoDictPropCondGood]) {
        condition = SENWiFiConditionGood;
    }
    
    return condition;
}

@end

@implementation SENSenseMetadata

static NSString* const SENSenseMetadataDictPropState = @"state";
static NSString* const SENSenseMetadataDictPropStateNormal = @"NORMAL";
static NSString* const SENSenseMetadataDictPropStateUnknown = @"UNKNOWN";
static NSString* const SENSenseMetadataDictPropColor = @"color";
static NSString* const SENSenseMetadataDictPropColorCharcoal = @"BLACK";
static NSString* const SENSenseMetadataDictPropColorCotton = @"WHITE";
static NSString* const SENSenseMetadataDictPropWiFi = @"wifi_info";

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        _state = [self stateFromValue:SENObjectOfClass(dict[SENSenseMetadataDictPropState],
                                                       [NSString class])];
        _color = [self colorFromValue:SENObjectOfClass(dict[SENSenseMetadataDictPropColor],
                                                       [NSString class])];
        _wiFi = [[SENSenseWiFiInfo alloc] initWithDictionary:dict[SENSenseMetadataDictPropWiFi]];
    }
    return self;
}

- (SENSenseState)stateFromValue:(NSString*)stateValue {
    SENSenseState state = SENSenseStateUnknown;
    NSString* upperValue = [stateValue uppercaseString];
    
    if ([upperValue isEqualToString:SENSenseMetadataDictPropStateNormal]) {
        state = SENSenseStateNormal;
    }
    
    return state;
}

- (SENSenseColor)colorFromValue:(NSString*)colorValue {
    SENSenseColor color = SENSenseColorUnknown;
    NSString* upperValue = [colorValue uppercaseString];
    
    if ([upperValue isEqualToString:SENSenseMetadataDictPropColorCharcoal]) {
        color = SENSenseColorCharcoal;
    } else if ([upperValue isEqualToString:SENSenseMetadataDictPropColorCotton]) {
        color = SENSenseColorCotton;
    }
    
    return color;
}

@end
