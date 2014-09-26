//
//  SENAPIDevice.m
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import "SENAPIDevice.h"
#import "SENDevice.h"

NSString* const SENAPIDeviceEndpoint = @"devices";
NSString* const SENAPIDevicePropertyDeviceId = @"device_id";
NSString* const SENAPIDevicePropertyType = @"type";
NSString* const SENAPIDevicePropertyTypeValueSense = @"SENSE";
NSString* const SENAPIDevicePropertyTypeValuePill = @"PILL";
NSString* const SENAPIDevicePropertyState = @"state";
NSString* const SENAPIDevicePropertyStateValueNormal = @"NORMAL";
NSString* const SENAPIDevicePropertyStateValueLowBattery = @"LOW_BATTERY";

@implementation SENAPIDevice

+ (SENDeviceType)typeFromString:(id)stringObj {
    SENDeviceType type = SENDeviceTypeSense;
    if ([stringObj isKindOfClass:[NSString class]]
        && [stringObj isEqualToString:SENAPIDevicePropertyTypeValuePill]) {
        type = SENDeviceTypePill;
    }
    return type;
}

+ (SENDeviceState)stateFromString:(id)stringObj {
    SENDeviceState state = SENDeviceStateNormal;
    if ([stringObj isKindOfClass:[NSString class]]) {
        if ([stringObj isEqualToString:SENAPIDevicePropertyStateValueLowBattery]) {
            state = SENDeviceStateLowBattery;
        }
    }
    return state;
}

+ (SENDevice*)deviceFromRawResponse:(id)rawResponse {
    SENDevice* device = nil;
    if ([rawResponse isKindOfClass:[NSDictionary class]]) {
        id deviceIdObj = [rawResponse valueForKey:SENAPIDevicePropertyDeviceId];
        id typeObj = [rawResponse valueForKey:SENAPIDevicePropertyType];
        id stateObj = [rawResponse valueForKey:SENAPIDevicePropertyState];
        
        NSString* deviceId = [deviceIdObj isKindOfClass:[NSString class]] ? deviceIdObj : nil;
        SENDeviceType type  = [self typeFromString:typeObj];
        SENDeviceState state = [self stateFromString:stateObj];
        
        device = [[SENDevice alloc] initWithDeviceId:deviceId type:type state:state];
    }
    return device;
}

+ (NSArray*)devicesFromRawResponse:(id)rawResponse {
    NSMutableArray* devices = nil;
    if ([rawResponse isKindOfClass:[NSArray class]]) {
        devices = [NSMutableArray arrayWithCapacity:[rawResponse count]];
        SENDevice* device = nil;
        
        for (id deviceObj in rawResponse) {
            device = [self deviceFromRawResponse:deviceObj];
            if (device != nil) {
                [devices addObject:device];
            }
        }
    }
    return devices;
}

+ (void)getPairedDevices:(SENAPIDataBlock)completion {
    if (!completion) return; // no block to callback?  let's stop here
    
    [SENAPIClient GET:SENAPIDeviceEndpoint parameters:nil completion:^(id data, NSError *error) {
        if (completion) completion ([self devicesFromRawResponse:data], error);
    }];
    
}

@end
