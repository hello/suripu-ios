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
@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        [self setPeripheral:peripheral];
        [self processDeviceId];
    }
    return self;
}

- (void)processDeviceId {
    NSDictionary* data = [[self peripheral] advertisingData];
    NSDictionary* serviceData = data[CBAdvertisementDataServiceDataKey];
    NSMutableString* deviceIdInHex = nil;
    
    if ([serviceData count] == 1) {
        NSData* deviceIdData = [serviceData allValues][0];
        const unsigned char* dataBuffer = (const unsigned char*)[deviceIdData bytes];
        if (dataBuffer) {
            NSInteger len = [deviceIdData length];
            deviceIdInHex = [[NSMutableString alloc] initWithCapacity:len];
            
            for (int i = 0; i < len; i++) {
                [deviceIdInHex appendString:[NSString stringWithFormat:@"%02lX", (unsigned long)dataBuffer[i]]];
            }
        }
    }
    
    [self setDeviceId:deviceIdInHex];
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@", [self name]];
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
