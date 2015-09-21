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

- (NSInteger)daysElapsed {
    NSDate *now = [NSDate date];
    NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay
                                               fromDate:self
                                                 toDate:now
                                                options:NSCalendarMatchStrictly];
    return [components day];
}

- (NSString*)elapsed {
    long days = [self daysElapsed];
    NSString* elapsed = nil;
    
    if (days < 1) {
        elapsed = NSLocalizedString(@"date.elapsed.today", nil);
    } else {
        NSString* format = nil;
        long value = days;
        
        if (days < 2) {
            format = NSLocalizedString(@"date.elapsed.day.format", nil);
        } else if (days < 7) {
            format = NSLocalizedString(@"date.elapsed.days.format", nil);
        } else if (days == 7) {
            format = NSLocalizedString(@"date.elapsed.week.format", nil);
            value = 1;
        } else if (days < 365) {
            format = NSLocalizedString(@"date.elapsed.weeks.format", nil);
            value = (long)ceilf(days/7.0f);
        } else if (days == 365) {
            format = NSLocalizedString(@"date.elapsed.year.format", nil);
            value = 1;
        } else {
            format = NSLocalizedString(@"date.elapsed.years.format", nil);
            value = (long)ceilf(days/365.0f);
        }
        
        elapsed = [NSString stringWithFormat:format, value];
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
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
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
    NSCalendarUnit flags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:otherDate];

    return ([components day] == [otherComponents day] && [components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

@end
