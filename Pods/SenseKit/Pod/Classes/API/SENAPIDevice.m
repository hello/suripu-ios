//
//  SENAPIDevice.m
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import "SENAPIDevice.h"
#import "SENDevice.h"
#import "Model.h"

NSString* const SENAPIDeviceErrorDomain = @"is.hello.api.device";

NSString* const SENAPIDeviceEndpoint = @"v1/devices";
NSString* const SENAPIDevicePathPill = @"pill";
NSString* const SENAPIDevicePathSense = @"sense";
NSString* const SENAPIDevicePathMetaData = @"info";

NSString* const SENAPIDevicePropertyDeviceId = @"device_id";
NSString* const SENAPIDevicePropertyType = @"type";
NSString* const SENAPIDevicePropertyTypeValueSense = @"SENSE";
NSString* const SENAPIDevicePropertyTypeValuePill = @"PILL";
NSString* const SENAPIDevicePropertyState = @"state";
NSString* const SENAPIDevicePropertyStateValueNormal = @"NORMAL";
NSString* const SENAPIDevicePropertyColor = @"color";
NSString* const SENAPIDevicePropertyColorBlack = @"BLACK";
NSString* const SENAPIDevicePropertyColorWhite = @"WHITE";
NSString* const SENAPIDevicePropertyColorRed = @"RED";
NSString* const SENAPIDevicePropertyColorBlue = @"BLUE";
NSString* const SENAPIDevicePropertyStateValueLowBattery = @"LOW_BATTERY";
NSString* const SENAPIDevicePropertyFirmwareVersion = @"firmware_version";
NSString* const SENAPIDevicePropertyLastSeen = @"last_updated";

@implementation SENAPIDevice

+ (SENDeviceType)typeFromString:(id)stringObj {
    SENDeviceType type = SENDeviceTypeSense;
    NSString* value = SENObjectOfClass(stringObj, [NSString class]);
    if ([value isEqualToString:SENAPIDevicePropertyTypeValuePill]) {
        type = SENDeviceTypePill;
    }
    return type;
}

+ (SENDeviceColor)colorFromString:(id)stringObj {
    SENDeviceColor color = SENDeviceColorUnknown;
    NSString* value = SENObjectOfClass(stringObj, [NSString class]);
    if ([value isEqualToString:SENAPIDevicePropertyColorBlack]) {
        color = SENDeviceColorBlack;
    } else if ([value isEqualToString:SENAPIDevicePropertyColorWhite]) {
        color = SENDeviceColorWhite;
    } else if ([value isEqualToString:SENAPIDevicePropertyColorBlue]) {
        color = SENDeviceColorBlue;
    } else if ([value isEqualToString:SENAPIDevicePropertyColorRed]) {
        color = SENDeviceColorRed;
    }
    return color;
}

+ (SENDeviceState)stateFromString:(id)stringObj {
    SENDeviceState state = SENDeviceStateUnknown;
    NSString* value = SENObjectOfClass(stringObj, [NSString class]);
    if ([value isEqualToString:SENAPIDevicePropertyStateValueLowBattery]) {
        state = SENDeviceStateLowBattery;
    } else if ([value isEqualToString:SENAPIDevicePropertyStateValueNormal]) {
        state = SENDeviceStateNormal;
    }
    return state;
}

+ (SENDevice*)deviceFromRawResponse:(id)rawResponse {
    SENDevice* device = nil;
    if ([rawResponse isKindOfClass:[NSDictionary class]]) {
        NSString* deviceId = SENObjectOfClass(rawResponse[SENAPIDevicePropertyDeviceId], [NSString class]);
        NSString* version = SENObjectOfClass(rawResponse[SENAPIDevicePropertyFirmwareVersion], [NSString class]);
        SENDeviceType type  = [self typeFromString:rawResponse[SENAPIDevicePropertyType]];
        SENDeviceState state = [self stateFromString:rawResponse[SENAPIDevicePropertyState]];
        SENDeviceColor color = [self colorFromString:rawResponse[SENAPIDevicePropertyColor]];
        NSDate* lastSeen = SENDateFromNumber(rawResponse[SENAPIDevicePropertyLastSeen]);
        
        device = [[SENDevice alloc] initWithDeviceId:deviceId
                                                type:type
                                               state:state
                                               color:color
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

+ (void)getSenseMetaData:(SENAPIDataBlock)completion {
    if (!completion) return;
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingPathComponent:SENAPIDevicePathMetaData];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENDeviceMetadata* senseMetadata = nil;
        
        if (error == nil && [data isKindOfClass:[NSDictionary  class]]) {
            senseMetadata = [[SENDeviceMetadata alloc] initWithDictionary:data
                                                                 withType:SENDeviceTypeSense];
        }
        
        completion (senseMetadata, error);
    }];
}

+ (void)getNumberOfAccountsForPairedSense:(NSString*)deviceId completion:(SENAPIDataBlock)completion {
    if (!completion) return;
    if ([deviceId length] == 0) {
        completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                             code:SENAPIDeviceErrorInvalidParam
                                         userInfo:nil]);
        return;
    }
    
    [self getSenseMetaData:^(SENDeviceMetadata* data, NSError *error) {
        NSError* metadataError = error;
        if (error == nil && ![[data deviceId] isEqualToString:deviceId]) {
            metadataError = [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                                code:SENAPIDeviceErrorUnexpectedResponse
                                            userInfo:nil];
            completion (nil, metadataError);
        } else {
            completion ([data pairedAccounts], metadataError);
        }
        
    }];
}

#pragma mark - Unregistering Devices

+ (void)unregisterDevice:(SENDevice*)device completion:(SENAPIDataBlock)completion {
    NSString* type = [device type] == SENDeviceTypePill ? SENAPIDevicePathPill : SENAPIDevicePathSense;
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingFormat:@"/%@/%@", type, [device deviceId]];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
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
    
    return [self unregisterDevice:device completion:completion];
}

+ (void)unregisterSense:(SENDevice*)device completion:(SENAPIDataBlock)completion {
    if ([device type] != SENDeviceTypeSense || [device deviceId] == nil) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                                 code:SENAPIDeviceErrorInvalidParam
                                             userInfo:nil]);
        }
        return;
    }
    
    return [self unregisterDevice:device completion:completion];
}

#pragma mark - Factory Reset

+ (void)removeAssociationsToSense:(SENDevice*)sense completion:(SENAPIDataBlock)completion {
    if ([sense type] != SENDeviceTypeSense || [sense deviceId] == nil) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                                 code:SENAPIDeviceErrorInvalidParam
                                             userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingFormat:@"/sense/%@/all", [sense deviceId]];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
}

@end
