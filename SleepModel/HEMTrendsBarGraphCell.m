//
//  HEMTrendsBarGraphCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBarGraphCell.h"
#import "HEMXAxisView.h"
#import "HEMBarChartView.h"

static CGFloat const HEMTrendsBarGraphBaseHeight = 233.0f;
static CGFloat const HEMTrendsBarGraphAveragesHeight = 52.0f;
static CGFloat const HEMTrendsBarGraphAveragesBotMargin = 20.0f;

@interface HEMTrendsBarGraphCell()

@property (weak, nonatomic) IBOutlet HEMBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet HEMXAxisView *xAxisView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesBottomConstraint;

@property (copy, nonatomic) NSArray<NSAttributedString*>* xTitles;
@property (copy, nonatomic) NSArray<NSNumber*>* dataPoints;
@property (copy, nonatomic) NSArray<NSNumber*>* highlightedIndices;
@property (assign, nonatomic) CGFloat barWidth;
@property (assign, nonatomic) CGFloat barSpacing;

@end

@implementation HEMTrendsBarGraphCell

+ (CGFloat)heightWithAverages:(BOOL)averages {
    CGFloat height = HEMTrendsBarGraphBaseHeight;
    if (averages) {
        height = height
                + HEMTrendsBarGraphAveragesHeight
                + HEMTrendsBarGraphAveragesBotMargin;
    }
    return height;
}

- (void)setAttributedXAxisValues:(NSArray<NSAttributedString*>*)xValues
                      dataPoints:(NSArray<NSNumber*>*)dataPoints
          highlightDataAtIndices:(NSArray<NSNumber*>*)highlightedIndices
                         spacing:(CGFloat)spacing {
    
    [self setXTitles:xValues];
    [self setBarSpacing:spacing];
    [self setDataPoints:dataPoints];
    [self setHighlightedIndices:highlightedIndices];
    [self calculateBarWidth];
    [self renderXTitles];
    [self renderBars];
}

- (void)calculateBarWidth {
    // check xAxisWidth, but any subviews can do.  If subview is bigger than cell
    // then it means the cell has not properly resized the subviews yet, which we
    // depend on so call layout manually
    CGFloat maxWidth = CGRectGetWidth([[self xAxisView] bounds]);
    if (maxWidth > CGRectGetWidth([self bounds])) {
        [self layoutIfNeeded];
        maxWidth = CGRectGetWidth([[self xAxisView] bounds]);
    }
    
    NSInteger count = [[self dataPoints] count];
    [self setBarWidth:(maxWidth - ((count - 1) * [self barSpacing])) / count];
}

- (void)renderXTitles {
    CGFloat startingX = 0.0f;
    CGFloat labelSpacing = 0.0f;
    CGFloat maxLabelWidth = MAXFLOAT;
    if ([[self xTitles] count] == 7) { // TODO: server bug.  titles = 7 != value count
//    if ([[self xTitles] count] == [[self dataPoints] count]) {
        // titles should just match bar width
        labelSpacing = [self barSpacing];
        maxLabelWidth = [self barWidth];
    } else {
        
    }
         
    [[self xAxisView] showLabelsFromX:startingX
                withAttributedStrings:[self xTitles]
                         labelSpacing:labelSpacing
                        maxLabelWidth:maxLabelWidth];
}

- (void)renderBars {
    [[self barChartView] setMaxValue:[self maxValue]];
    [[self barChartView] setHighlightedBarColor:[self highlightedBarColor]];
    [[self barChartView] setNormalBarColor:[self normalBarColor]];
    [[self barChartView] setBarSpacing:[self barSpacing]];
    [[self barChartView] setBarWidth:[self barWidth]];
    [[self barChartView] updateBarChartWith:[self dataPoints]
                         highlightedIndices:[self highlightedIndices]];
}

@end
