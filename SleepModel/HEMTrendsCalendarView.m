//
//  HEMTrendsCalendarView.m
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSDate+HEMRelative.h"

#import "HEMTrendsCalendarView.h"
#import "HEMTrendsCalendarMonthView.h"
#import "HEMMultiTitleView.h"
#import "HEMTrendsDisplayPoint.h"

static CGFloat const HEMTrendsCalendarMonthHorzSpacing = 40.0f;
static CGFloat const HEMTrendsCalendarMonthVertSpacing = 32.0f;

@interface HEMTrendsCalendarView()

@property (nonatomic, strong) NSMutableArray<HEMTrendsCalendarMonthView*>* monthViews;

@end

@implementation HEMTrendsCalendarView

+ (CGFloat)heightWithSections:(NSInteger)sections
                      forType:(HEMTrendsCalendarType)type
                     maxWidth:(CGFloat)maxWidth {
    CGFloat height = 0.0f;
    
    if (type == HEMTrendsCalendarTypeMonth) {
        height = [HEMTrendsCalendarMonthView heightForMonthWithRows:sections maxWidth:maxWidth];
    } else {
        NSDate* monthInQuarter = [NSDate date];
        CGFloat maxQuarterWidth = (maxWidth / 2) - (HEMTrendsCalendarMonthHorzSpacing / 2);
        CGFloat topHalfHeight = 0.0f, secondHalfHeight = 0.0f;
        
        for (NSInteger sectIndex = 0; sectIndex < sections; sectIndex++) {
            CGFloat heightOfMonth = [HEMTrendsCalendarMonthView heightForMonthInQuarter:monthInQuarter
                                                                               maxWidth:maxQuarterWidth];
            
            monthInQuarter = [monthInQuarter previousMonth];
            
            if (sectIndex < 2 && secondHalfHeight < heightOfMonth) {
                secondHalfHeight = heightOfMonth;
            } else if (sectIndex >= 2 && topHalfHeight < heightOfMonth) {
                topHalfHeight = heightOfMonth;
            }
        }
        
        return topHalfHeight + HEMTrendsCalendarMonthVertSpacing + secondHalfHeight;
    }
    
    return height;
}

- (NSCalendar*)calendar {
    static NSCalendar* calendar = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

- (void)clearMonthData {
    [[self monthViews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self monthViews] removeAllObjects];
}

- (void)updateWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                  titles:(NSArray<NSAttributedString*>*)attributedTitles {
    if (![self monthViews]) {
        [self setMonthViews:[NSMutableArray arrayWithCapacity:[values count]]];
    }
    [[self monthViews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([self type] == HEMTrendsCalendarTypeMonth) {
        [self renderMonthWithValues:values titles:attributedTitles];
    } else {
        [self renderQuarterWithValues:values titles:attributedTitles];
    }
}

- (void)renderQuarterWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                         titles:(NSArray<NSAttributedString*>*)attributedTitles {
    
    NSDate* monthDate = [NSDate date];
    NSDate* month = [monthDate monthsFromNow:-([values count] - 1)];
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGFloat monthWidth = (fullWidth / 2) - (HEMTrendsCalendarMonthHorzSpacing / 2);
    
    CGRect frame = CGRectZero;
    frame.size.width = monthWidth;
    frame.size.height = [HEMTrendsCalendarMonthView heightForMonthInQuarter:month maxWidth:monthWidth];
    
    NSInteger sectionIndex = 0;
    for (NSArray<HEMTrendsDisplayPoint*>* monthData in values) {
        HEMTrendsCalendarMonthView* monthView = [[HEMTrendsCalendarMonthView alloc] initWithFrame:frame];
        NSAttributedString* title = nil;
        if (sectionIndex < [attributedTitles count]) {
            title = attributedTitles[sectionIndex];
        }
        [monthView showMonthInQuarterWithValues:monthData titles:title forMonth:month];
        
        [self addSubview:monthView];
        [[self monthViews] addObject:monthView];
        
        month = [month nextMonth];
        BOOL nextRow = ++sectionIndex % 2 == 0;
        
        CGFloat nextHeight = [HEMTrendsCalendarMonthView heightForMonthInQuarter:month
                                                                        maxWidth:monthWidth];
        if (!nextRow && CGRectGetHeight([monthView bounds]) < nextHeight) {
            CGRect monthFrame = [monthView frame];
            monthFrame.size.height = nextHeight;
            [monthView setFrame:monthFrame];
        }
        
        frame.size.height = nextHeight;

        if (nextRow) {
            frame.origin.x = 0.0f;
            frame.origin.y = CGRectGetMaxY([monthView frame]) + HEMTrendsCalendarMonthVertSpacing;
        } else {
            frame.origin.x = CGRectGetMaxX([monthView frame]) + HEMTrendsCalendarMonthHorzSpacing;
        }
    }
}

- (void)renderMonthWithValues:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)values
                       titles:(NSArray<NSAttributedString*>*)localizedTitles {
    
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGRect frame = CGRectZero;
    frame.size.width = fullWidth;
    frame.size.height = [HEMTrendsCalendarMonthView heightForMonthWithRows:[values count]
                                                                  maxWidth:fullWidth];
    
    HEMTrendsCalendarMonthView* monthView = [[HEMTrendsCalendarMonthView alloc] initWithFrame:frame];
    [monthView showCurrentMonthWithValues:values titles:localizedTitles];
    [self addSubview:monthView];
    [[self monthViews] addObject:monthView];
}

@end
