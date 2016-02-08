//
//  HEMTrendsCalendarView.m
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCalendarView.h"

static CGFloat const HEMTrendsCalendarRowHeight = 32.0f;
static CGFloat const HEMTrendsCalendarTitleHeight = 13.0f;
static CGFloat const HEMTrendsCalendarTitleMargin = 12.0f;
static CGFloat const HEMTrendsCalendarRowSpacing = 15.0f;

static CGFloat const HEMTrendsCalendarMultiMonthHeight = 289.0f;

static NSInteger const HEMTrendsCalendarMaxRowInMonth = 5;
static NSInteger const HEMTrendsCalendarDaysPerRow = 7;

@implementation HEMTrendsCalendarView

+ (CGFloat)heightWithDays:(NSInteger)days {
    static NSCalendar* calendar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
     calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    
    NSDateComponents* comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger daysItCanDisplayInCurrentRow = [comps weekday] - 1; // for yesterday
    if (days == 0) {
        daysItCanDisplayInCurrentRow = HEMTrendsCalendarDaysPerRow;
    }
    
    CGFloat rowsNeeded = (days - daysItCanDisplayInCurrentRow) / HEMTrendsCalendarDaysPerRow;
    NSInteger rows = roundCGFloat(rowsNeeded + 0.5f);
    
    CGFloat height = 0.0f;
    if (rows <= HEMTrendsCalendarMaxRowInMonth) {
        height = HEMTrendsCalendarTitleHeight + HEMTrendsCalendarTitleMargin;
        CGFloat rowSpacingNeeded = ((rows - 1) * HEMTrendsCalendarRowSpacing);
        height += (rows * HEMTrendsCalendarRowHeight) + rowSpacingNeeded;
    } else {
        height = HEMTrendsCalendarMultiMonthHeight;
    }
    
    return height;
}

@end
