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
static CGFloat const HEMTrendsCalendarBotMargin = 18.0f;

@interface HEMTrendsCalendarViewCell()

@property (weak, nonatomic) IBOutlet HEMTrendsCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet HEMTrendsAverageView *averagesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesBottomConstraint;

@end

@implementation HEMTrendsCalendarViewCell

+ (CGFloat)heightForAveragesView {
    return HEMTrendsCalendarAveragesHeight + HEMTrendsCalendarAveragesBottom;
}

+ (CGFloat)heightForNumberOfDays:(NSInteger)days withAverages:(BOOL)showAverages {
    CGFloat totalHeight = HEMTrendsCalendarCellTitleHeightWithSeparator;
    totalHeight += HEMTrendsCalendarCellTitleSeparatorBotMargin;
    totalHeight += [HEMTrendsCalendarView heightWithDays:days];
    totalHeight += HEMTrendsCalendarBotMargin;
    
    if (showAverages) {
        totalHeight += [self heightForAveragesView];
    }
    
    return totalHeight;
}

@end
