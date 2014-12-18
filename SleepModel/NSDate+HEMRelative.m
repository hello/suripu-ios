//
//  NSDate+HEMRelative.m
//  Sense
//
//  Created by Jimmy Lu on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import "NSDate+HEMRelative.h"

@implementation NSDate (HEMRelative)

- (NSString*)elapsed {
    NSDate *now = [NSDate date];
    long days = (long)fabs(ceilf([self timeIntervalSinceDate:now] / 86400.0f)) ;
    NSString* elapsed = nil;
    
    if (days < 1) {
        elapsed = NSLocalizedString(@"date.elapsed.today", nil);
    } else {
        NSString* format = nil;
        if (days < 7) {
            format = NSLocalizedString(@"date.elapsed.days.format", nil);
            elapsed = [NSString stringWithFormat:format, days];
        } else if (days < 365) {
            format = NSLocalizedString(@"date.elapsed.weeks.format", nil);
            elapsed = [NSString stringWithFormat:format, (long)ceilf(days/7.0f)];
        } else {
            format = NSLocalizedString(@"date.elapsed.years.format", nil);
            elapsed = [NSString stringWithFormat:format, (long)ceilf(days/365.0f)];
        }
    }
    
    return elapsed;
}

- (NSString*)timeAgo {
    // wrapping SORelativeDateTransformer in case we no longer use it in the future
    NSValueTransformer* xform = [SORelativeDateTransformer registeredTransformer];
    return [xform transformedValue:self];
}

@end
