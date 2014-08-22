//
//  HEMWifiCenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HEMWifiCenter.h"

@implementation HEMWifiCenter

+ (NSDictionary*)connectedWifiInfo {
    NSArray *interfaces = (__bridge id)CNCopySupportedInterfaces();
    NSDictionary* info = nil;
    for (NSString *interface in interfaces) {
        id networkInfo = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        NSLog(@"network info class %@", NSStringFromClass([networkInfo class]));
        if ([networkInfo isKindOfClass:[NSDictionary class]] && [networkInfo count] >0) {
            info = networkInfo;
            break;
        }
    }
    return info;
}

+ (NSString*)connectedWifiSSID {
    NSDictionary* info = [self connectedWifiInfo];
    return info != nil ? [info valueForKey:@"SSID"] : nil;
}

@end
