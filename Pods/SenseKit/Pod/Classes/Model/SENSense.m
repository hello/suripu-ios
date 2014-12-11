//
//  SENSense.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "LGPeripheral.h"

#import "SENSense+Protected.h"

@interface SENSense()

@property (nonatomic, copy, readwrite) NSString* deviceId;
@property (nonatomic, assign, readwrite) SENSenseMode mode;
@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        [self setPeripheral:peripheral];
        [self processAdvertisementData:[peripheral advertisingData]];
    }
    return self;
}

- (void)processAdvertisementData:(NSDictionary*)data {
    SENSenseMode mode = SENSenseModeUnknown;
    NSDictionary* serviceData = data[CBAdvertisementDataServiceDataKey];
    NSMutableString* deviceIdInHex = nil;
    
    if ([serviceData count] == 1) {
        NSData* deviceIdData = [serviceData allValues][0];
        const unsigned char* dataBuffer = (const unsigned char*)[deviceIdData bytes];
        if (dataBuffer) {
            NSInteger len = [deviceIdData length];
            NSInteger deviceIdLength = len;
            
            // per Pang, if device id data is odd in length, the last byte indicates
            // the mode Sense is in.  If even, then that byte is not being set by the
            // firmware.  If we don't handle it and the firmware code is pushed, then
            // people will never be able to configure Sense b/c device id on server
            // and one processed here will never match!
            if (len % 2 != 0) {
                deviceIdLength = len - 1;
                mode = dataBuffer[deviceIdLength] == '1'?SENSenseModePairing:SENSenseModeNormal;
            }
            
            deviceIdInHex = [[NSMutableString alloc] initWithCapacity:deviceIdLength];
            for (int i = 0; i < deviceIdLength; i++) {
                [deviceIdInHex appendString:[NSString stringWithFormat:@"%02lX", (unsigned long)dataBuffer[i]]];
            }
        }
    }
    
    [self setDeviceId:deviceIdInHex];
    [self setMode:mode];
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@, in mode: %ld", [self name], (long)[self mode]];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    
    SENSense* other = object;
    return [other deviceId] != nil && [[self deviceId] isEqualToString:[other deviceId]];
}

- (NSUInteger)hash {
    return [[self deviceId] hash];
}

@end
