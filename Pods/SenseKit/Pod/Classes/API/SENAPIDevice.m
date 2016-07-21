//
//  SENAPIDevice.m
//  Pods
//
//  Created by Jimmy Lu on 9/19/14.
//
//

#import "SENAPIDevice.h"
#import "Model.h"

NSString* const SENAPIDeviceErrorDomain = @"is.hello.api.device";

static NSString* const SENAPIDeviceEndpoint = @"v2/devices";
static NSString* const SENAPIDeviceInfoPath = @"info";
static NSString* const SENAPIDeviceSensePath = @"sense";
static NSString* const SENAPIDevicePillPath = @"pill";

static NSString* const SENAPIDeviceOTAEndpoint = @"v1/ota";
static NSString* const SENAPIDeviceOTAStatusPath = @"status";
static NSString* const SENAPIDeviceOTARequestPath = @"request_ota";

@implementation SENAPIDevice

+ (void)getPairedDevices:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIDeviceEndpoint parameters:nil completion:^(id data, NSError *error) {
        SENPairedDevices* devices = nil;
        NSDictionary* dict = SENObjectOfClass(data, [NSDictionary class]);
        if (!error && dict) {
            devices = [[SENPairedDevices alloc] initWithDictionary:dict];
        }
        completion (devices, error);
    }];
    
}

+ (void)getPairingInfo:(SENAPIDataBlock)completion {
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingPathComponent:SENAPIDeviceInfoPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENDevicePairingInfo* pairingInfo = nil;
        NSDictionary* dict = SENObjectOfClass(data, [NSDictionary class]);
        if (!error && dict) {
            pairingInfo = [[SENDevicePairingInfo alloc] initWithDictionary:dict];
        }
        completion (pairingInfo, error);
    }];
}

#pragma mark - Unregistering Devices

+ (void)unregisterDevice:(SENDeviceMetadata*)device completion:(SENAPIDataBlock)completion {
    NSString* type = nil;
    if ([device isKindOfClass:[SENSenseMetadata class]]) {
        type = SENAPIDeviceSensePath;
    } else if ([device isKindOfClass:[SENPillMetadata class]]) {
        type = SENAPIDevicePillPath;
    }
    
    if (!type || ![device uniqueId]) {
        completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                             code:SENAPIDeviceErrorInvalidParam
                                         userInfo:nil]);
        return;
    }
    
    NSString* path = [SENAPIDeviceEndpoint stringByAppendingFormat:@"/%@/%@", type, [device uniqueId]];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
}

+ (void)unregisterPill:(SENPillMetadata*)pillMetadata completion:(SENAPIDataBlock)completion {
    return [self unregisterDevice:pillMetadata completion:completion];
}

+ (void)unregisterSense:(SENSenseMetadata*)senseMetadata completion:(SENAPIDataBlock)completion {
    return [self unregisterDevice:senseMetadata completion:completion];
}

#pragma mark - Factory Reset

+ (void)removeAssociationsToSense:(SENSenseMetadata*)senseMetadata completion:(SENAPIDataBlock)completion {
    if (![senseMetadata uniqueId]) {
        completion (nil, [NSError errorWithDomain:SENAPIDeviceErrorDomain
                                             code:SENAPIDeviceErrorInvalidParam
                                         userInfo:nil]);
        return;
    }
    
    NSString* sensePath = [SENAPIDeviceEndpoint stringByAppendingPathComponent:SENAPIDeviceSensePath];
    NSString* path = [sensePath stringByAppendingFormat:@"/%@/all", [senseMetadata uniqueId]];
    [SENAPIClient DELETE:path parameters:nil completion:completion];
}

#pragma mark - OTA

+ (void)getOTAStatus:(SENAPIDataBlock)completion {
    NSString* path = [SENAPIDeviceOTAEndpoint stringByAppendingPathComponent:SENAPIDeviceOTAStatusPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENDFUStatus* status = nil;
        NSDictionary* dict = SENObjectOfClass(data, [NSDictionary class]);
        if (!error && dict) {
            status = [[SENDFUStatus alloc] initWithDictionary:dict];
        }
        completion (status, error);
    }];
}

+ (void)forceOTA:(SENAPIDataBlock)completion {
    NSString* path = [SENAPIDeviceOTAEndpoint stringByAppendingPathComponent:SENAPIDeviceOTARequestPath];
    [SENAPIClient POST:path parameters:nil completion:completion];
}

@end
