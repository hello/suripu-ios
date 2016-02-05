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
#import "HEMTrendsAverageView.h"
#import "HEMTrendsDisplayPoint.h"

static CGFloat const HEMTrendsBarGraphBaseHeight = 233.0f;
static CGFloat const HEMTrendsBarGraphAveragesHeight = 52.0f;
static CGFloat const HEMTrendsBarGraphAveragesBotMargin = 20.0f;

@interface HEMTrendsBarGraphCell()

@property (weak, nonatomic) IBOutlet HEMBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet HEMXAxisView *xAxisView;
@property (weak, nonatomic) IBOutlet HEMTrendsAverageView *averagesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *averagesBottomConstraint;

@property (copy, nonatomic) NSArray<NSAttributedString*>* xTitles;
@property (copy, nonatomic) NSArray<NSArray<HEMTrendsDisplayPoint*>*>* displayPoints;
@property (strong, nonatomic) NSArray<HEMTrendsDisplayPoint*>* combinedPoints;
@property (copy, nonatomic) NSArray<NSArray<NSNumber*>*>* highlightedIndices;
@property (copy, nonatomic) NSArray<NSArray<NSString*>*>* highlightedTitles;
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

- (void)setAverageTitles:(NSArray<NSString*>*)titles
                  values:(NSArray<NSString*>*)values {
    
    if (!titles || !values || [titles count] != [values count] || [titles count] != 3) {
        [[self averagesHeightConstraint] setConstant:0.0f];
        [[self averagesBottomConstraint] setConstant:0.0f];
    } else {
        [[self averagesHeightConstraint] setConstant:HEMTrendsBarGraphAveragesHeight];
        [[self averagesBottomConstraint] setConstant:HEMTrendsBarGraphAveragesBotMargin];
        
        [[[self averagesView] average1TitleLabel] setTextColor:[self averageTitleColor]];
        [[[self averagesView] average2TitleLabel] setTextColor:[self averageTitleColor]];
        [[[self averagesView] average3TitleLabel] setTextColor:[self averageTitleColor]];
        [[[self averagesView] average1ValueLabel] setTextColor:[self averageValueColor]];
        [[[self averagesView] average2ValueLabel] setTextColor:[self averageValueColor]];
        [[[self averagesView] average3ValueLabel] setTextColor:[self averageValueColor]];
        
        [[[self averagesView] average1TitleLabel] setText:[titles firstObject]];
        [[[self averagesView] average2TitleLabel] setText:titles[1]];
        [[[self averagesView] average3TitleLabel] setText:[titles lastObject]];
        
        [[[self averagesView] average1ValueLabel] setText:[values firstObject]];
        [[[self averagesView] average2ValueLabel] setText:values[1]];
        [[[self averagesView] average3ValueLabel] setText:[values lastObject]];
    }
}

- (void)updateGraphWithTitles:(NSArray<NSAttributedString*>*)titles
                displayPoints:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)displayPoints
                      spacing:(CGFloat)spacing {
    // combine all the sections in to 1 continguous array since the chart view
    // does not care where it stops
    NSMutableArray* combinedPoints = [NSMutableArray arrayWithCapacity:90];
    for (NSArray* dataPoints in displayPoints) {
        [combinedPoints addObjectsFromArray:dataPoints];
    }
    
    [self setXTitles:titles];
    [self setDisplayPoints:displayPoints];
    [self setCombinedPoints:combinedPoints];
    [self setBarSpacing:spacing];
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
    
    NSInteger count = [[self combinedPoints] count];
    [self setBarWidth:(maxWidth - ((count - 1) * [self barSpacing])) / count];
}

- (void)renderXTitles {
    CGFloat startingX = 0.0f;
    CGFloat labelSpacing = 0.0f;
    CGFloat maxLabelWidth = MAXFLOAT;
    if ([[self xTitles] count] == [[self combinedPoints] count]) {
        labelSpacing = [self barSpacing];
        maxLabelWidth = [self barWidth];
    } else {
        // TODO: handle this!
    }
         
    [[self xAxisView] showLabelsFromX:startingX
                withAttributedStrings:[self xTitles]
                         labelSpacing:labelSpacing
                        maxLabelWidth:maxLabelWidth];
}

- (void)renderBars {
    [[self barChartView] setMaxValue:[self maxValue]];
    [[self barChartView] setMinValue:[self minValue]];
    [[self barChartView] setHighlightedBarColor:[self highlightedBarColor]];
    [[self barChartView] setNormalBarColor:[self normalBarColor]];
    [[self barChartView] setBarSpacing:[self barSpacing]];
    [[self barChartView] setBarWidth:[self barWidth]];
    [[self barChartView] updateBarChartWith:[self combinedPoints]];
}

@end
