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
#import "HEMTrendsDisplayPoint.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsCalendarCellTitleHeightWithSeparator = 49.0f;
static CGFloat const HEMTrendsCalendarCellTitleSeparatorBotMargin = 8.0f;
static CGFloat const HEMTrendsCalendarAveragesHeight = 52.0f;
static CGFloat const HEMTrendsCalendarAveragesBottom = 20.0f;
static CGFloat const HEMTrendsCalendarHorzMargin = 20.0f;
static CGFloat const HEMTrendsCalendarBotMargin = 18.0f;

@interface HEMTrendsCalendarViewCell()

@property (weak, nonatomic) IBOutlet HEMTrendsCalendarView *calendarView;
@property (strong, nonatomic) NSArray<NSAttributedString*>*sectionTitles;
@property (strong, nonatomic) NSArray<NSArray<HEMTrendsDisplayPoint*>*>* scores;

@end

@implementation HEMTrendsCalendarViewCell

+ (CGFloat)heightForAveragesView {
    return HEMTrendsCalendarAveragesHeight + HEMTrendsCalendarAveragesBottom;
}

+ (CGFloat)heightWithNumberOfSections:(NSInteger)sections
                              forType:(HEMTrendsCalendarType)type
                         withAverages:(BOOL)averages
                                width:(CGFloat)width {
    
    CGFloat contentWidth = width - (HEMTrendsCalendarHorzMargin * 2);
    CGFloat totalHeight = HEMTrendsCalendarCellTitleHeightWithSeparator;
    totalHeight += HEMTrendsCalendarCellTitleSeparatorBotMargin;
    totalHeight += [HEMTrendsCalendarView heightWithSections:sections
                                                     forType:type
                                                    maxWidth:contentWidth];
    totalHeight += HEMTrendsCalendarBotMargin;
    
    if (averages) {
        totalHeight += [self heightForAveragesView];
    }
    
    return totalHeight;
}

- (void)layoutSubviewsIfNeeded {
    if (CGRectGetWidth([self bounds]) < CGRectGetWidth([[self calendarView] bounds])) {
        [self layoutIfNeeded];
    }
}

- (void)setSectionTitles:(NSArray<NSAttributedString*>*)sectionTitles
                  scores:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)scores {
    
    if (sectionTitles
        && [[self sectionTitles] isEqualToArray:sectionTitles]
        && scores
        && [[self scores] isEqualToArray:scores]) {
        return;
    }
    
    [self layoutSubviewsIfNeeded];
    [self setSectionTitles:sectionTitles];
    [self setScores:scores];
    [[self calendarView] setType:[self type]];
    [[self calendarView] updateWithValues:scores titles:sectionTitles];
}

@end
