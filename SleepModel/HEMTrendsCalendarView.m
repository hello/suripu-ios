//
//  HEMTrendsCalendarView.m
//  Sense
//
//  Created by Jimmy Lu on 2/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCalendarView.h"
#import "HEMTrendsCalendarMonthView.h"
#import "HEMMultiTitleView.h"

static CGFloat const HEMTrendsCalendarTitleHeight = 13.0f;
static CGFloat const HEMTrendsCalendarTitleMargin = 12.0f;

static CGFloat const HEMTrendsCalendarMonthHorzSpacing = 40.0f;
static CGFloat const HEMTrendsCalendarMonthVertSpacing = 32.0f;

static CGFloat const HEMTrendsCalendarMultiMonthHeight = 289.0f;
static CGFloat const HEMTrendsCalendarMiniMonthHeight = 131.0f;

@interface HEMTrendsCalendarView()

@property (nonatomic, strong) NSMutableArray<HEMMultiTitleView*>* multiTitleViews;

@end

@implementation HEMTrendsCalendarView

+ (CGFloat)heightWithDays:(NSInteger)days maxWidth:(CGFloat)maxWidth {
    CGFloat height = 0.0f;
    
    NSInteger rows = [HEMTrendsCalendarMonthView rowsForDays:days];
    NSInteger months = [HEMTrendsCalendarMonthView monthsForRows:rows];
    if (months == 1) {
        height = HEMTrendsCalendarTitleHeight + HEMTrendsCalendarTitleMargin;
        height += [HEMTrendsCalendarMonthView heightForMonthWithRows:rows maxWidth:maxWidth];
    } else {
        height = HEMTrendsCalendarMultiMonthHeight;
    }
    
    return height;
}

- (HEMMultiTitleView*)multiViewAtIndex:(NSInteger)index {
    if (![self multiTitleViews]) {
        [self setMultiTitleViews:[NSMutableArray arrayWithCapacity:2]];
    }
    
    if (index < [[self multiTitleViews] count]) {
        return [self multiTitleViews][index];
    } else {
        CGFloat heightWithSpacing = HEMTrendsCalendarTitleHeight - HEMTrendsCalendarTitleMargin;
        CGFloat vertDistanceBetweenMonths
            = heightWithSpacing
            + HEMTrendsCalendarMiniMonthHeight
            + HEMTrendsCalendarMonthVertSpacing;

        CGRect frame = CGRectZero;
        frame.origin.y = index * vertDistanceBetweenMonths;
        frame.size.width = CGRectGetWidth([self bounds]);
        frame.size.height = HEMTrendsCalendarTitleHeight;
        HEMMultiTitleView* titleView = [[HEMMultiTitleView alloc] initWithFrame:frame];
        [[self multiTitleViews] addObject:titleView];
        [self addSubview:titleView];
        return titleView;
    }
}

- (void)updateTitlesWith:(NSArray<NSArray<NSAttributedString*>*>*)attributedTitles {
    [[self multiTitleViews] makeObjectsPerformSelector:@selector(clear)];

    HEMMultiTitleView* titleView = nil;
    CGFloat width = CGRectGetWidth([self bounds]);
    CGFloat size = [HEMTrendsCalendarMonthView sizeForEachDayWithWidth:width];
    
    NSInteger titleIndex = 0;
    NSInteger sectionIndex = 0;
    NSInteger titleViewIndex = 0;
    CGFloat x = 0.0f;
    
    for (NSArray* section in attributedTitles) {
        titleView = [self multiViewAtIndex:titleViewIndex];
        
        for (NSAttributedString* title in section) {
            [titleView addLabelWithText:title atX:x maxLabelWidth:size];
            x = ++titleIndex * (size + HEMTrendsCalMonthDaySpacing);
        }

        if (++sectionIndex % 2 == 1) {
            x = (width / 2.0f) + (HEMTrendsCalendarMonthHorzSpacing / 2.0f);
        } else {
            titleViewIndex++;
            x = 0.0f;
        }
    }
}

@end
