//
//  HEMTrendsCalendarViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCalendarViewCell.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsCalendarViewCellBaseHeight = 90.0f;
static CGFloat const HEMTrendsCalendarMonthRowSpacing = 15.0f;
static CGFloat const HEMTrendsCalendarMonthRowHeight = 32.0f;
static CGFloat const HEMTrendsCalendarAveragesHeight = 77.0f;
static CGFloat const HEMTrendsCalendarMultiMonthHeight = 270.0f;

@interface HEMTrendsCalendarViewCell()

@end

@implementation HEMTrendsCalendarViewCell

+ (CGFloat)heightForMonthWithNumberOfRows:(NSInteger)rows showAverages:(BOOL)averages {
    CGFloat totalHeight = HEMTrendsCalendarViewCellBaseHeight;
    CGFloat rowSpacing = rows > 0 ? ((rows - 1) * HEMTrendsCalendarMonthRowSpacing) : 0.0f;
    totalHeight = totalHeight + (rows * HEMTrendsCalendarMonthRowHeight) + rowSpacing;
    if (averages) {
        totalHeight = totalHeight + HEMTrendsCalendarAveragesHeight;
    }
    return totalHeight;
}

+ (CGFloat)heightForMultiMonthWithAverages:(BOOL)averages {
    CGFloat totalHeight = HEMTrendsCalendarViewCellBaseHeight + HEMTrendsCalendarMultiMonthHeight;
    if (averages) {
        totalHeight = totalHeight + HEMTrendsCalendarAveragesHeight;
    }
    return totalHeight;
}

@end
