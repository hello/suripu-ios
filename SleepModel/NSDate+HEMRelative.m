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
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [calendar components:NSDayCalendarUnit
                                               fromDate:self
                                                 toDate:now options:NSCalendarMatchStrictly];
    long days = components.day;
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

- (NSDate*)dateAtMidnight
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    return [calendar dateFromComponents:[calendar components:preservedComponents fromDate:self]];
}

- (NSDate*)nextDay {
    return [self daysFromNow:1];
}

- (NSDate*)previousDay {
    return [self daysFromNow:-1];
}

- (NSDate*)daysFromNow:(NSInteger)days {
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [NSDateComponents new];
    components.day = days;
    return [calendar dateByAddingComponents:components
                                     toDate:self
                                    options:0];
}

- (BOOL)isOnSameDay:(NSDate*)otherDate
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSCalendarUnit flags = (NSMonthCalendarUnit| NSYearCalendarUnit | NSDayCalendarUnit);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:otherDate];

    return ([components day] == [otherComponents day] && [components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

@end
