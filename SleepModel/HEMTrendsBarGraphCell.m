//
//  HEMTrendsBarGraphCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBarGraphCell.h"
#import "HEMMultiTitleView.h"
#import "HEMBarChartView.h"
#import "HEMTrendsAverageView.h"
#import "HEMTrendsDisplayPoint.h"
#import "HEMDashLine.h"

static CGFloat const HEMTrendsBarGraphBaseHeight = 243.0f;
static CGFloat const HEMTrendsBarGraphAveragesHeight = 52.0f;
static CGFloat const HEMTrendsBarGraphAveragesBotMargin = 20.0f;
static CGFloat const HEMTrendsBarHighlightLabelWidth = 35.0f;
static CGFloat const HEMTrendsBarHighlightLabelHeight = 20.0f;
static CGFloat const HEMTrendsBarHighlightLabelCornerRadius = 2.0f;
static CGFloat const HEMTrendsBarHighlightLabelSpacing = 2.0f;
static CGFloat const HEMTrendsBarCellAnimeDuration = 0.2f;
static CGFloat const HEMTrendsBarDashLineWidth = 1.0f;
static CGFloat const HEMTrendsBarDashLineSpacing = 4.0f;
static CGFloat const HEMTrendsBarDashLineYOffset = 2.0f;

@interface HEMTrendsBarGraphCell()

@property (weak, nonatomic) IBOutlet HEMBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet HEMMultiTitleView *multiTitleView;

@property (copy, nonatomic) NSArray<NSAttributedString*>* xTitles;
@property (copy, nonatomic) NSArray<NSArray<HEMTrendsDisplayPoint*>*>* displayPoints;
@property (strong, nonatomic) NSArray<HEMTrendsDisplayPoint*>* combinedPoints;
@property (copy, nonatomic) NSArray<NSArray<NSNumber*>*>* highlightedIndices;
@property (copy, nonatomic) NSArray<NSArray<NSString*>*>* highlightedTitles;
@property (assign, nonatomic) CGFloat barWidth;
@property (assign, nonatomic) CGFloat barSpacing;
@property (strong, nonatomic) NSMutableArray<UILabel*>* highlightLabels;
@property (strong, nonatomic) NSMutableArray<UIView*>* dashLines;

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

- (void)updateGraphWithTitles:(NSArray<NSAttributedString*>*)titles
                displayPoints:(NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)displayPoints
                      spacing:(CGFloat)spacing {
    
    if (titles
        && [[self xTitles] isEqualToArray:titles]
        && displayPoints
        && [[self displayPoints] isEqualToArray:displayPoints]) {
        return; // nothing to update since it's already done
    }
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
    CGFloat maxWidth = CGRectGetWidth([[self multiTitleView] bounds]);
    if (maxWidth > CGRectGetWidth([self bounds])) {
        [self layoutIfNeeded];
        maxWidth = CGRectGetWidth([[self multiTitleView] bounds]);
    }
    
    NSInteger count = [[self combinedPoints] count];
    [self setBarWidth:(maxWidth - ((count - 1) * [self barSpacing])) / count];
}

- (void)renderXTitles {
    [[self multiTitleView] clear];
    [self clearDashLines];
    
    if ([[self displayPoints] count] == 1
        && [[[self displayPoints] firstObject] count] == [[self xTitles] count]) { // 1 section
        
        CGFloat nextX = 0.0f;
        for (NSAttributedString* title in [self xTitles]) {
            [[self multiTitleView] addLabelWithText:title atX:nextX maxLabelWidth:[self barWidth]];
            nextX += [self barSpacing] + [self barWidth];
        }
    } else {
        CGFloat minTitleX = CGRectGetMinX([[self multiTitleView] frame]);
        NSInteger numberOfSections = [[self displayPoints] count];
        NSInteger minBarCount = numberOfSections > 2 ? 5 : 3;
        NSInteger sectionBarCount = 0;
        CGFloat viewWidth = CGRectGetMaxX([[self multiTitleView] bounds]);
        CGFloat lastTitleX = viewWidth;
        for (NSInteger idx = numberOfSections - 1; idx >= 0; idx--) {
            NSArray* sectionOfPoints = [self displayPoints][idx];
            sectionBarCount = [sectionOfPoints count];
            
            CGFloat spacing = ((sectionBarCount - 1) * [self barSpacing]);
            CGFloat distance = (sectionBarCount * [self barWidth]) + spacing;
            lastTitleX -= distance;
            
            if (sectionBarCount >= minBarCount
                && idx < [[self xTitles] count]
                && lastTitleX >= 0.0f) {
                NSAttributedString* title = [self xTitles][idx];
                
                CGFloat dashLineX = lastTitleX + minTitleX;
                if (dashLineX > [self barWidth] + minTitleX) {
                    [self addDashLineForSectionAtX:dashLineX];
                }
                
                [[self multiTitleView] addLabelWithText:title
                                                    atX:lastTitleX + HEMTrendsBarDashLineSpacing
                                          maxLabelWidth:MAXFLOAT];
            }
        }
    }
}

- (void)clearDashLines {
    [[self dashLines] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self dashLines] removeAllObjects];
}

- (void)addDashLineForSectionAtX:(CGFloat)x {
    CGFloat maxGraphY = CGRectGetMaxY([[self barChartView] frame]);
    CGFloat y = CGRectGetMinY([[self multiTitleView] frame]);
    CGRect frame = CGRectZero;
    frame.origin.x = ceilCGFloat(x);
    frame.origin.y = y + HEMTrendsBarDashLineYOffset;
    frame.size.width = HEMTrendsBarDashLineWidth;
    frame.size.height = maxGraphY - y - HEMTrendsBarDashLineYOffset;
    
    if (![self dashLines]) {
        [self setDashLines:[NSMutableArray arrayWithCapacity:[[self displayPoints] count]]];
    }
    
    HEMDashLine* dashLine = [[HEMDashLine alloc] initWithFrame:frame];
    [dashLine setDashColor:[self dashLineColor]];
    
    [[self contentView] addSubview:dashLine];
    [[self dashLines] addObject:dashLine];
}

- (void)renderBars {
    [[self highlightLabels] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self barChartView] setMaxValue:[self maxValue]];
    [[self barChartView] setMinValue:[self minValue]];
    [[self barChartView] setHighlightedBarColor:[self highlightedBarColor]];
    [[self barChartView] setNormalBarColor:[self normalBarColor]];
    [[self barChartView] setBarSpacing:[self barSpacing]];
    [[self barChartView] setBarWidth:[self barWidth]];
    [[self barChartView] updateBarChartWith:[self combinedPoints] completion:^(NSInteger minIndex, NSInteger maxIndex) {
        [self showHighlightLabelAtIndex:minIndex];
        [self showHighlightLabelAtIndex:maxIndex];
    }];
}

- (void)showHighlightLabelAtIndex:(NSInteger)index {
    CGRect frame = [[self barChartView] frameOfBarAtIndex:index relativeTo:[self contentView]];
    if (!CGRectIsEmpty(frame)) {
        HEMTrendsDisplayPoint* displayPoint = [self combinedPoints][index];
        CGFloat halfHeight = (HEMTrendsBarHighlightLabelHeight / 2);
        CGFloat centerY = CGRectGetMinY(frame) - halfHeight - HEMTrendsBarHighlightLabelSpacing;
        CGPoint center = CGPointMake(CGRectGetMidX(frame), centerY);
        UILabel* label = [self highlightLabelWith:displayPoint withCenter:center];
        [[self contentView] addSubview:label];
        [UIView animateWithDuration:HEMTrendsBarCellAnimeDuration animations:^{
            [label setAlpha:1.0f];
        }];
        
        if (![self highlightLabels]) {
            [self setHighlightLabels:[NSMutableArray arrayWithCapacity:2]];
        }
        [[self highlightLabels] addObject:label];
    }
}

- (UILabel*)highlightLabelWith:(HEMTrendsDisplayPoint*)displayPoint withCenter:(CGPoint)center {
    CGRect labelFrame = CGRectZero;
    labelFrame.size = CGSizeMake(HEMTrendsBarHighlightLabelWidth, HEMTrendsBarHighlightLabelHeight);
    
    CGFloat value = [[displayPoint value] CGFloatValue];
    NSString* text = [NSString stringWithFormat:[self highlightLabelTextFormat], value];
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setBackgroundColor:[self highlightLabelColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[self highlightTextFont]];
    [label setText:text];
    [label setAlpha:0.0f];
    [label setCenter:center];
    [[label layer] setCornerRadius:HEMTrendsBarHighlightLabelCornerRadius];
    [label setClipsToBounds:YES];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    return label;
}

@end
