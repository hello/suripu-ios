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
    if ([stringObj isKindOfClass:[NSString class]]
        && [stringObj isEqualToString:SENAPIDevicePropertyTypeValuePill]) {
        type = SENDeviceTypePill;
    }
    return type;
}

+ (SENDeviceColor)colorFromString:(id)stringObj {
    SENDeviceColor color = SENDeviceColorUnknown;
    if ([stringObj isKindOfClass:[NSString class]]) {
        if ([stringObj isEqualToString:SENAPIDevicePropertyColorBlack]) {
            color = SENDeviceColorBlack;
        } else if ([stringObj isEqualToString:SENAPIDevicePropertyColorWhite]) {
            color = SENDeviceColorWhite;
        } else if ([stringObj isEqualToString:SENAPIDevicePropertyColorBlue]) {
            color = SENDeviceColorBlue;
        } else if ([stringObj isEqualToString:SENAPIDevicePropertyColorRed]) {
            color = SENDeviceColorRed;
        }
    }
    return color;
}

+ (SENDeviceState)stateFromString:(id)stringObj {
    SENDeviceState state = SENDeviceStateUnknown;
    if ([stringObj isKindOfClass:[NSString class]]) {
        if ([stringObj isEqualToString:SENAPIDevicePropertyStateValueLowBattery]) {
            state = SENDeviceStateLowBattery;
        } else if ([stringObj isEqualToString:SENAPIDevicePropertyStateValueNormal]) {
            state = SENDeviceStateNormal;
        }
    }
    return state;
}

+ (NSDate*)dateFromObject:(id)dateObject {
    NSDate* lastSeen = nil;
    if ([dateObject respondsToSelector:@selector(doubleValue)]) {
        double timeInMs = [dateObject doubleValue];
        // this is a work around an issue on the server + firmware where it
        // returns 0 for "last_updated" on certain occassions right after a
        // device is linked to the user's account.
        if (timeInMs > 0) {
            lastSeen = [NSDate dateWithTimeIntervalSince1970:timeInMs / 1000];
        } else {
            lastSeen = [NSDate date];
        }
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
        id colorObj = [rawResponse valueForKey:SENAPIDevicePropertyColor];
        
        NSString* deviceId = [deviceIdObj isKindOfClass:[NSString class]] ? deviceIdObj : nil;
        NSString* version = [firmwareVerObj isKindOfClass:[NSString class]] ? firmwareVerObj : nil;
        SENDeviceType type  = [self typeFromString:typeObj];
        SENDeviceState state = [self stateFromString:stateObj];
        SENDeviceColor color = [self colorFromString:colorObj];
        NSDate* lastSeen = [self dateFromObject:lastSeenObj];
        
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
