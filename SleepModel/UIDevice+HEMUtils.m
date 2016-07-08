//
//  UIDevice+HEMUtils.m
//  Sense
//
//  Created by Jimmy Lu on 1/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <sys/sysctl.h>

#import "UIDevice+HEMUtils.h"

@implementation UIDevice (HEMUtils)

+ (NSString*)currentDeviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char* result = malloc(size);
    sysctlbyname("hw.machine", result, &size, NULL, 0);
    
    NSString* deviceModel = [NSString stringWithUTF8String:result];
    free(result);
    
    return deviceModel;
}

+ (CGFloat)batteryPercentage {
    return [[self currentDevice] batteryLevel];
}

@end
