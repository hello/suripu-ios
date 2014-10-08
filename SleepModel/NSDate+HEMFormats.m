//
//  NSDate+HEMFormats.m
//  Sense
//
//  Created by Jimmy Lu on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSDate+HEMFormats.h"

@implementation NSDate (HEMFormats)

- (NSString*)ago:(long)time dividend:(double)dividend type:(NSString*)type {
    long units = MAX(((long) fabs((time / dividend))), 1); // never display 0
    
    NSString* typeFormat = type;
    if (units > 1) typeFormat = [typeFormat stringByAppendingString:@"s"];
    
    NSString* key = [NSString stringWithFormat:@"time.format.%@.ago", typeFormat];
    return [NSString stringWithFormat:NSLocalizedString(key, nil), units];
}

- (NSString*)timeAgo {
    NSString* ago = nil;
    NSTimeInterval timeIntervalSinceNow = [self timeIntervalSinceNow];
    
    if (timeIntervalSinceNow > -60.0f) {
        ago = [self ago:timeIntervalSinceNow dividend:1.0f type:@"second"];
    } else if (timeIntervalSinceNow > -3600.0f) {
        ago = [self ago:timeIntervalSinceNow dividend:60.0f type:@"minute"];
    } else if (timeIntervalSinceNow > -86400.0f) {
        ago = [self ago:timeIntervalSinceNow dividend:3600.0f type:@"hour"];
    } else if (timeIntervalSinceNow > (-604800)) {
        ago = [self ago:timeIntervalSinceNow dividend:86400.0f type:@"day"];
    } else {
        ago = [self ago:timeIntervalSinceNow dividend:4233600 type:@"week"];
    }
    return ago;
}

@end
