//
//  SENSense.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "LGPeripheral.h"
#import "SENSense.h"

static unsigned char const kSENSenseVoiceByte = 0x22;
static NSInteger const kSENSenseVoiceHwVersionLoc = 2;

@interface SENSense()

@property (nonatomic, copy, readwrite) NSString* deviceId;
@property (nonatomic, copy, readwrite) NSString* macAddress;
@property (nonatomic, assign, readwrite) SENSenseMode mode;
@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        [self processAdvertisementData:[peripheral advertisingData]];
    }
    return self;
}

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral andDeviceId:(NSString*)deviceId {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _deviceId = [deviceId copy];
    }
    return self;
}

- (void)processAdvertisementData:(NSDictionary*)data {
    NSDictionary* serviceData = data[CBAdvertisementDataServiceDataKey];
    if ([serviceData count] == 1) {
        NSData* deviceIdData = [serviceData allValues][0];
        [self processAdvertisementServiceData:deviceIdData];
    }
    
    [self processManufacturerData:data[CBAdvertisementDataManufacturerDataKey]];
}

- (void)processManufacturerData:(NSData*)manufacturerData {
    if ([manufacturerData length] >= kSENSenseVoiceHwVersionLoc + 1) {
        const unsigned char* bytes = (const unsigned char*)[manufacturerData bytes];
        unsigned char hwByte = bytes[kSENSenseVoiceHwVersionLoc];
        if (hwByte == kSENSenseVoiceByte) {
            _version = SENSenseAdvertisedVersionVoice;
        }
    }
}

- (void)processAdvertisementServiceData:(NSData*)serviceData {
    NSMutableString* deviceIdInHex = nil;
    SENSenseMode mode = SENSenseModeUnknown;
    
    if (serviceData) { // serviceData is the device id data
        const unsigned char* dataBuffer = (const unsigned char*)[serviceData bytes];
        if (dataBuffer) {
            NSInteger len = [serviceData length];
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

- (NSString*)macAddressFrom:(unsigned char*)deviceId deviceIdLength:(NSInteger)length {
    // determine mac address from device id (based on code from fw)
    int macSize = 6;
    char* mac[6] = {0x5c,0x6b,0x4f,0,0,0};
    mac[3] = deviceId[length - 3];
    mac[4] = deviceId[length - 2];
    mac[5] = deviceId[length - 1];
    
    NSMutableString* macAddress = [NSMutableString new];
    for (int i = 0; i < macSize; i++) {
        [macAddress appendString:[NSString stringWithFormat:@"%@%02lX",
                                  [macAddress length] > 0 ? @":" : @"",
                                  (unsigned long)mac[i]]];
    }
    
    return macAddress;
}

- (NSString*)macAddress {
    if ([[self deviceId] length] == 0) {
        return nil;
    }
    
    if (!_macAddress) {
        NSMutableData* deviceIdData = [NSMutableData data];
        int idx;
        for (idx = 0; idx+2 <= [[self deviceId] length]; idx+=2) {
            NSRange range = NSMakeRange(idx, 2);
            NSString* hexStr = [[self deviceId] substringWithRange:range];
            NSScanner* scanner = [NSScanner scannerWithString:hexStr];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            [deviceIdData appendBytes:&intValue length:1];
        }
        NSInteger len = [deviceIdData length];
        const unsigned char* dataBuffer = (const unsigned char*)[deviceIdData bytes];
        _macAddress = [self macAddressFrom:dataBuffer deviceIdLength:len];
    }
    
    return _macAddress;
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@, mac: %@, in mode: %ld, id: %@",
            [self name], [self macAddress], (long)[self mode], [self deviceId]];
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
