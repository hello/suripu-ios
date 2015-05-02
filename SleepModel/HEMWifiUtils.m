//
//  HEMWifiCenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HEMWifiUtils.h"

static CGFloat const HEMWiFiRssiSignalNone = 0.0f;
static CGFloat const HEMWiFiRssiSignalLow = -90.0f;
static CGFloat const HEMWiFiRssiSignalMed = -60.0f;

@implementation HEMWifiUtils

+ (NSDictionary*)connectedWifiInfo {
    CFArrayRef interfacesRef = CNCopySupportedInterfaces();
    if (!interfacesRef) return nil;
    
    NSArray *interfaces = (__bridge id)interfacesRef;
    NSDictionary* info = nil;
    for (NSString *interface in interfaces) {
        CFDictionaryRef networkInfoRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)interface);
        if (networkInfoRef) {
            info = [NSDictionary dictionaryWithDictionary:(__bridge id)networkInfoRef];
            CFRelease(networkInfoRef);
            if ([info count] > 0) {
                break;
            }
        }
    }
    
    CFRelease(interfacesRef);
    return info;
}

+ (NSString*)connectedWifiSSID {
    NSDictionary* info = [self connectedWifiInfo];
    return info != nil ? [info valueForKey:@"SSID"] : nil;
}

+ (UIImage*)wifiIconForRssi:(long)rssi {
    NSString* imageName = @"wifiIcon";
    if (rssi == HEMWiFiRssiSignalNone) {
        imageName = [imageName stringByAppendingString:@"None"];
    } else if (rssi > HEMWiFiRssiSignalMed) {
        imageName = [imageName stringByAppendingString:@"High"];
    } else if (rssi > HEMWiFiRssiSignalLow) {
        imageName = [imageName stringByAppendingString:@"Medium"];
    } else {
        imageName = [imageName stringByAppendingString:@"Low"];
    }
    return [UIImage imageNamed:imageName];
}

@end
