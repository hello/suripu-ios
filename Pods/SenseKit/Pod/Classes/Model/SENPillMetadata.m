//
//  SENPillMetadata.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import "SENPillMetadata.h"
#import "Model.h"

static NSString* const SENPillMetadataDictPropColor = @"color";
static NSString* const SENPillMetadataDictPropColorBlue = @"BLUE";
static NSString* const SENPillMetadataDictPropColorRed = @"RED";
static NSString* const SENPillMetadataDictPropState = @"state";
static NSString* const SENPillMetadataDictPropStateNormal = @"NORMAL";
static NSString* const SENPillMetadataDictPropStateLowBattery = @"LOW_BATTERY";
static NSString* const SENPillMetadataDictPropStateUnknown = @"UNKNOWN";
static NSString* const SENPillMetadataDictPropBatteryLevel = @"battery_level";

@interface SENPillMetadata()

@property (nonatomic, assign) SENPillState state;
@property (nonatomic, assign) SENPillColor color;
@property (nonatomic, strong) NSNumber* batteryLevel;

@end

@implementation SENPillMetadata

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        _state = [self stateFromValue:SENObjectOfClass(dict[SENPillMetadataDictPropState],
                                                       [NSString class])];
        _color = [self colorFromValue:SENObjectOfClass(dict[SENPillMetadataDictPropColor],
                                                       [NSString class])];
        _batteryLevel = SENObjectOfClass(dict[SENPillMetadataDictPropBatteryLevel],
                                         [NSNumber class]);
    }
    return self;
}

- (SENPillState)stateFromValue:(NSString*)stateValue {
    SENPillState state = SENPillStateUnknown;
    NSString* upperValue = [stateValue uppercaseString];
    
    if ([upperValue isEqualToString:SENPillMetadataDictPropStateNormal]) {
        state = SENPillStateNormal;
    } else if ([upperValue isEqualToString:SENPillMetadataDictPropStateLowBattery]) {
        state = SENPillStateLowBattery;
    }
    
    return state;
}

- (SENPillColor)colorFromValue:(NSString*)colorValue {
    SENPillColor color = SENPillColorUnknown;
    NSString* upperValue = [colorValue uppercaseString];
    
    if ([upperValue isEqualToString:SENPillMetadataDictPropColorBlue]) {
        color = SENPillColorBlue;
    } else if ([upperValue isEqualToString:SENPillMetadataDictPropColorRed]) {
        color = SENPillColorRed;
    }
    
    return color;
}

@end
