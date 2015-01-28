//
//  HEMBluetoothUtils.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "HEMBluetoothUtils.h"

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

@end
