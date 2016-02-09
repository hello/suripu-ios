//
//  HEMTrendsCalendarMonthView.m
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCalendarMonthView.h"

CGFloat const HEMTrendsCalMonthDaySpacing = 15.0f;
static CGFloat const HEMTrendsCalMonthDaysInWeek = 7;
static NSInteger const HEMTrendsCalMonthMaxRows = 5;

@implementation HEMTrendsCalendarMonthView

+ (CGFloat)sizeForEachDayWithWidth:(CGFloat)width {
    CGFloat spacingNeeded = (HEMTrendsCalMonthDaysInWeek - 1) * HEMTrendsCalMonthDaySpacing;
    return ceilCGFloat((width - spacingNeeded) / HEMTrendsCalMonthDaysInWeek);
}

+ (NSCalendar*)calendar {
    static NSCalendar* calendar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

+ (NSInteger)rowsForDays:(NSInteger)days {
    NSDateComponents* comps = [[self calendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger daysItCanDisplayInCurrentRow = [comps weekday] - 1; // for yesterday
    if (days == 0) {
        daysItCanDisplayInCurrentRow = HEMTrendsCalMonthDaysInWeek;
    }
    
    CGFloat rowsNeeded = (days - daysItCanDisplayInCurrentRow) / HEMTrendsCalMonthDaysInWeek;
    return roundCGFloat(rowsNeeded + 0.5f);
}

+ (NSInteger)monthsForRows:(NSInteger)rows {
    return roundCGFloat((rows / HEMTrendsCalMonthMaxRows) + 0.5f);
}

+ (CGFloat)heightForMonthWithRows:(NSInteger)rows maxWidth:(CGFloat)maxWidth {
    CGFloat size = [self sizeForEachDayWithWidth:maxWidth];
    CGFloat spacingNeeded = (rows - 1) * HEMTrendsCalMonthDaySpacing;
    return (size * rows) + spacingNeeded;
}

@end
