//
//  HEMBluetoothUtils.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "HEMBluetoothUtils.h"

static CGFloat const HEMBluetoothRetryDelay = 2.0f;

static CBCentralManager* manager = nil;

@implementation HEMBluetoothUtils

+ (void)initialize {
    NSDictionary* options = @{CBCentralManagerOptionShowPowerAlertKey : @(NO)};
    manager = [[CBCentralManager alloc] initWithDelegate:nil
                                                   queue:dispatch_get_main_queue()
                                                 options:options];
}

+ (BOOL)isBleSupported {
    return [manager state] == CBCentralManagerStateUnsupported;
}

+ (BOOL)isBluetoothOn {
    return [manager state] == CBCentralManagerStatePoweredOn;
}

+ (BOOL)stateAvailable {
    return [manager state] != CBCentralManagerStateUnknown
        && [manager state] != CBCentralManagerStateResetting;
}

+ (void)whenBleStateAvailable:(HEMBluetoothStateHandler)completion {
    if (![self isBleSupported]) {
        completion (NO);
    } else if ([self stateAvailable]) {
        completion ([self isBluetoothOn]);
    } else {
        int64_t delayInSecs = (int64_t) (HEMBluetoothRetryDelay* NSEC_PER_SEC);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            [self whenBleStateAvailable:completion];
        });   
    }
}

@end
