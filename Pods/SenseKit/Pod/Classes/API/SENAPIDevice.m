//
//  SENAPIDevice.m
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import "SENAPIDevice.h"
#import "SENDevice.h"

NSString* const SENAPIDeviceErrorDomain = @"is.hello.api.device";

NSString* const SENAPIDeviceEndpoint = @"devices";
NSString* const SENAPIDevicePathPill = @"pill";

NSString* const SENAPIDevicePropertyDeviceId = @"device_id";
NSString* const SENAPIDevicePropertyType = @"type";
NSString* const SENAPIDevicePropertyTypeValueSense = @"SENSE";
NSString* const SENAPIDevicePropertyTypeValuePill = @"PILL";
NSString* const SENAPIDevicePropertyState = @"state";
NSString* const SENAPIDevicePropertyStateValueNormal = @"NORMAL";
NSString* const SENAPIDevicePropertyStateValueLowBattery = @"LOW_BATTERY";
NSString* const SENAPIDevicePropertyFirmwareVersion = @"firmware_version";
NSString* const SENAPIDevicePropertyLastSeen = @"last_updated";

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

+ (NSDate*)dateFromObject:(id)dateObject {
    NSDate* lastSeen = nil;
    // jimmy: strangely, last_updated is converted to a string...  is it too big
    // for a NSNUmber?
    if ([dateObject respondsToSelector:@selector(doubleValue)]) {
        lastSeen = [NSDate dateWithTimeIntervalSince1970:[dateObject doubleValue] / 1000];
    }
    return lastSeen;
}

+ (SENDevice*)deviceFromRawResponse:(id)rawResponse {
    SENDevice* device = nil;
    if ([rawResponse isKindOfClass:[NSDictionary class]]) {
        id deviceIdObj = [rawResponse valueForKey:SENAPIDevicePropertyDeviceId];
        id typeObj = [rawResponse valueForKey:SENAPIDevicePropertyType];
        id stateObj = [rawResponse valueForKey:SENAPIDevicePropertyState];
        id firmwareVerObj = [rawResponse valueForKey:SENAPIDevicePropertyFirmwareVersion];
        id lastSeenObj = [rawResponse valueForKey:SENAPIDevicePropertyLastSeen];
        
        NSString* deviceId = [deviceIdObj isKindOfClass:[NSString class]] ? deviceIdObj : nil;
        NSString* version = [firmwareVerObj isKindOfClass:[NSString class]] ? firmwareVerObj : nil;
        SENDeviceType type  = [self typeFromString:typeObj];
        SENDeviceState state = [self stateFromString:stateObj];
        NSDate* lastSeen = [self dateFromObject:lastSeenObj];
        
        device = [[SENDevice alloc] initWithDeviceId:deviceId
                                                type:type
                                               state:state
                                     firmwareVersion:version
                                            lastSeen:lastSeen];
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

+ (void)unregisterPill:(SENDevice*)device completion:(SENAPIDataBlock)completion {
    if ([device type] != SENDeviceTypePill || [device deviceId] == nil) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                                 code:SENAPIDeviceErrorInvalidParam
                                             userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingFormat:@"/%@/%@",
                      SENAPIDevicePathPill, [device deviceId]];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
}

@end
