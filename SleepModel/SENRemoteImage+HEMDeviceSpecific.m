//
//  SENRemoteImage+HEMDeviceSpecific.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENRemoteImage+HEMDeviceSpecific.h"

@implementation SENRemoteImage (HEMDeviceSpecific)

- (NSString*)uriForCurrentDevice {
    CGFloat deviceScale = [[UIScreen mainScreen] scale];
    NSString* imageUri = [self normalUri];
    if (deviceScale >= 3.0f) {
        imageUri = [self tripeScaleUri];
    } else if (deviceScale >= 2.0f) {
        imageUri = [self doubleScaleUri];
    }
    return imageUri;
}

@end
