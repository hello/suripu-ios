//
//  HEMTrendsCalendarViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCalendarViewCell.h"
#import "HEMTrendsCalendarView.h"
#import "HEMTrendsAverageView.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsCalendarCellTitleHeightWithSeparator = 49.0f;
static CGFloat const HEMTrendsCalendarCellTitleSeparatorBotMargin = 8.0f;
static CGFloat const HEMTrendsCalendarAveragesHeight = 52.0f;
static CGFloat const HEMTrendsCalendarAveragesBottom = 20.0f;
static CGFloat const HEMTrendsCalendarHorzMargin = 20.0f;
static CGFloat const HEMTrendsCalendarBotMargin = 18.0f;

@interface HEMTrendsCalendarViewCell()

@property (weak, nonatomic) IBOutlet HEMTrendsCalendarView *calendarView;

@end

@implementation HEMTrendsCalendarViewCell

+ (CGFloat)heightForAveragesView {
    return HEMTrendsCalendarAveragesHeight + HEMTrendsCalendarAveragesBottom;
}

+ (CGFloat)heightForNumberOfDays:(NSInteger)days
                    withAverages:(BOOL)showAverages
                        maxWidth:(CGFloat)width {
    
    CGFloat contentWidth = width - (HEMTrendsCalendarHorzMargin * 2);
    CGFloat totalHeight = HEMTrendsCalendarCellTitleHeightWithSeparator;
    totalHeight += HEMTrendsCalendarCellTitleSeparatorBotMargin;
    totalHeight += [HEMTrendsCalendarView heightWithDays:days maxWidth:contentWidth];
    totalHeight += HEMTrendsCalendarBotMargin;
    
    if (showAverages) {
        totalHeight += [self heightForAveragesView];
    }
    
    return totalHeight;
}

- (void)layoutSubviewsIfNeeded {
    if (CGRectGetWidth([self bounds]) < CGRectGetWidth([[self calendarView] bounds])) {
        [self layoutIfNeeded];
    }
}

- (void)setSectionTitles:(NSArray<NSArray<NSAttributedString*>*>*)sectionTitles {
    [self layoutSubviewsIfNeeded];
    [[self calendarView] updateTitlesWith:sectionTitles];
}

@end
