//
//  HEMTrendsBaseCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"
#import "HEMTrendsAverageView.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsAveragesHeight = 52.0f;
static CGFloat const HEMTrendsAveragesBotMargin = 20.0f;

@implementation HEMTrendsBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleLabel] setFont:[UIFont trendsTitleFont]];
    [[self titleLabel] setTextColor:[UIColor trendsTitleColor]];
    [[self titleSeparator] setBackgroundColor:[UIColor trendsTitleDividerColor]];
}

- (void)setAverageTitles:(NSArray<NSAttributedString*>*)titles
                  values:(NSArray<NSAttributedString*>*)values {
    
    if (!titles || !values || [titles count] != [values count] || [titles count] != 3) {
        [[self averagesHeightConstraint] setConstant:0.0f];
        [[self averagesBottomConstraint] setConstant:0.0f];
    } else {
        [[self averagesHeightConstraint] setConstant:HEMTrendsAveragesHeight];
        [[self averagesBottomConstraint] setConstant:HEMTrendsAveragesBotMargin];
        
        [[[self averagesView] average1TitleLabel] setAttributedText:[titles firstObject]];
        [[[self averagesView] average2TitleLabel] setAttributedText:titles[1]];
        [[[self averagesView] average3TitleLabel] setAttributedText:[titles lastObject]];
        
        [[[self averagesView] average1ValueLabel] setAttributedText:[values firstObject]];
        [[[self averagesView] average2ValueLabel] setAttributedText:values[1]];
        [[[self averagesView] average3ValueLabel] setAttributedText:[values lastObject]];
    }
}

@end
