//
//  HEMTrendCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>
#import <SenseKit/SENTrend.h>
#import "HEMTrendCollectionViewCell.h"
#import "HEMScopePickerView.h"
#import "HEMGraphSectionOverlayView.h"
#import "HEMBarGraphView.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

@interface HEMTrendCollectionViewCell () <HEMScopePickerViewDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat min;
@property (nonatomic) HEMTrendCellGraphType graphType;
@property (nonatomic, strong) NSMutableArray* labeledIndexes;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSDateFormatter* dayOfWeekFormatter;
@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@property (nonatomic, getter=isMaxValueVisible) NSUInteger maxIndex;
@property (nonatomic, getter=isMinValueVisible) NSUInteger minIndex;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* graphRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* graphLeftConstraint;
@end

@implementation HEMTrendCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.scopePickerView.delegate = self;
    self.overlayView.boldLastElement = NO;
    self.overlayView.showSeparatorLines = YES;
    self.topLabelType = HEMTrendCellGraphLabelTypeDate;
    self.bottomLabelType = HEMTrendCellGraphLabelTypeNone;
    self.numberOfGraphSections = 7;
    self.lineGraphView.alpha = 0;
    [self configureDateFormatters];
    [self configureLineGraphView];
}

- (void)configureDateFormatters
{
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"MMM d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEEEE";
    self.monthFormatter = [NSDateFormatter new];
    self.monthFormatter.dateFormat = @"MMM";
}

- (void)configureLineGraphView
{
    CGFloat leftConstant = 0, rightConstant = 0;
    if (self.numberOfGraphSections > 0 && self.numberOfGraphSections >= self.points.count) {
        CGFloat sectionWidth = CGRectGetWidth(self.bounds)/self.numberOfGraphSections;
        rightConstant = sectionWidth/2;
        leftConstant = sectionWidth/2;
    }
    if (self.graphRightConstraint.constant != rightConstant
        || self.graphLeftConstraint.constant != leftConstant) {
        self.graphLeftConstraint.constant = leftConstant;
        self.graphRightConstraint.constant = rightConstant;
        [self.lineGraphView setNeedsUpdateConstraints];
    }
    CGFloat topRed, topGreen, topBlue, bottomRed, bottomGreen, bottomBlue, alpha;
    [[UIColor trendGraphTopColor] getRed:&topRed green:&topGreen blue:&topBlue alpha:&alpha];
    [[UIColor trendGraphBottomColor] getRed:&bottomRed green:&bottomGreen blue:&bottomBlue alpha:&alpha];
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        topRed, topGreen, topBlue, 1.0,
        bottomRed, bottomGreen, bottomBlue, 1.0
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    CGColorSpaceRelease(colorspace);

    self.lineGraphView.dataSource = self;
    self.lineGraphView.delegate = self;
    self.lineGraphView.sizePoint = 5.f;
    self.lineGraphView.colorTop = [UIColor clearColor];
    self.lineGraphView.colorLine = [[UIColor tintColor] colorWithAlphaComponent:0.4f];
    self.lineGraphView.colorBottom = [UIColor whiteColor];
    self.lineGraphView.gradientBottom = gradient;
    self.lineGraphView.enableBezierCurve = YES;
    self.lineGraphView.alwaysDisplayPopUpLabels = YES;
    self.lineGraphView.alwaysDisplayDots = YES;
    self.lineGraphView.colorBackgroundPopUplabel = [UIColor clearColor];
    self.lineGraphView.userInteractionEnabled = NO;
    self.lineGraphView.labelFont = [UIFont sensorGraphNumberFont];
    self.lineGraphView.colorPoint = [UIColor clearColor];
    self.lineGraphView.enableXAxisLabel = YES;
    self.lineGraphView.animationGraphEntranceTime = 0;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.lineGraphView.alpha = 0;
    self.barGraphView.alpha = 0;
    self.overlayView.hidden = YES;
    [self.scopePickerView setButtonsWithTitles:nil selectedIndex:0];
    [self.overlayView setSectionFooters:nil headers:nil];
}

- (void)setTimeScopesWithOptions:(NSArray*)options selectedOptionIndex:(NSUInteger)selectedIndex
{
    [self.scopePickerView setButtonsWithTitles:options selectedIndex:selectedIndex];
}

- (void)showGraphOfType:(HEMTrendCellGraphType)type withData:(NSArray*)data
{
    BOOL showBarGraph = type == HEMTrendCellGraphTypeBar;
    BOOL showLineGraph = type == HEMTrendCellGraphTypeLine;
    self.points = data;
    self.graphType = type;
    NSArray* values = [data valueForKey:NSStringFromSelector(@selector(yValue))];
    NSArray* sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
    NSNumber* max = [sortedValues lastObject];
    for (int i = 0; i < sortedValues.count; i++) {
        NSNumber* number = sortedValues[i];
        if ([number floatValue] > 0) {
            self.minIndex = [values indexOfObject:number];
            if (showLineGraph) {
                self.minIndex += 1;
            }
            break;
        }
    }
    self.maxIndex = [values indexOfObject:max];
    if (showLineGraph) {
        self.maxIndex += 1;
    }
    if (showBarGraph) {
        [self layoutIfNeeded];
        [self.barGraphView setValues:data];
    }
    else if (showLineGraph) {
        [self configureLineGraphView];
    }
    [self.lineGraphView reloadGraph];
    if (HEMTrendCellGraphTypeNone)
        self.overlayView.hidden = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.barGraphView.alpha = showBarGraph ? 1 : 0;
        self.lineGraphView.alpha = showLineGraph ? 1 : 0;
    }];
}

- (NSArray*)sectionIndexValuesOfType:(HEMTrendCellGraphLabelType)type
{
    NSMutableArray* labels = [[NSMutableArray alloc] initWithCapacity:self.labeledIndexes.count];
    NSArray* indexes = [self.labeledIndexes sortedArrayUsingSelector:@selector(compare:)];
    int counter = 0;
    for (NSNumber* index in indexes) {
        SENTrendDataPoint* dataPoint = self.points[[index integerValue]];
        NSString* formattedValue = nil;
        switch (type) {
        case HEMTrendCellGraphLabelTypeValue: {
            if (dataPoint.yValue == 0)
                formattedValue = NSLocalizedString(@"empty-data", nil);
            else
                formattedValue = [NSString stringWithFormat:@"%.0f", dataPoint.yValue];
        } break;
        case HEMTrendCellGraphLabelTypeDate:
            formattedValue = [self.dateFormatter stringFromDate:dataPoint.date];
            break;
        case HEMTrendCellGraphLabelTypeDayOfWeek: {
            if (dataPoint.date)
                formattedValue = [self.dayOfWeekFormatter stringFromDate:dataPoint.date];
            else
                formattedValue = [self dayOfWeekForIndex:counter % 7];
        } break;
        case HEMTrendCellGraphLabelTypeMonth:
            formattedValue = [self.monthFormatter stringFromDate:dataPoint.date];
            break;
        case HEMTrendCellGraphLabelTypeHourValue:
            formattedValue = [NSString stringWithFormat:@"%.1fh", dataPoint.yValue / 60];
            break;
        case HEMTrendCellGraphLabelTypeNone:
        default:
            break;
        }
        if (formattedValue)
            [labels addObject:formattedValue];
        counter++;
    }
    return labels;
}

- (NSString*)dayOfWeekForIndex:(int)index
{
    NSArray* weekDaySymbols = self.dayOfWeekFormatter.veryShortWeekdaySymbols;
    return index < [weekDaySymbols count] ? [weekDaySymbols[index] uppercaseString] : nil;
}

#pragma mark HEMScopePickerViewDelegate

- (void)didTapButtonWithText:(NSString*)text
{
    [self.delegate didTapTimeScopeInCell:self withText:text];
}

#pragma mark BEMSimpleLineGraphDataSource

// @discussion
// Pads the line graph on the left and right with extra points to center
// the actually relevant points inside each graphed section. Only relevant
// because the graphs extend to the edges of the view, but the data is
// presumed to be only from the middle centers of the end sections
- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView*)graph
{
    NSInteger const HEMTrendMinimumPoints = 3;
    if (self.graphType == HEMTrendCellGraphTypeNone
        || self.points.count < HEMTrendMinimumPoints) {
        return 0;
    } else if (self.graphType == HEMTrendCellGraphTypeBar) {
        return self.points.count;
    } else if (self.graphType == HEMTrendCellGraphTypeLine) {
        return self.points.count + 2;
    }
    return 0;
}

// @discussion
// Reuses the first and last data points as an indentation buffer.
// Additional details available in discussion of `numberOfPointsInLineGraph:`
- (CGFloat)lineGraph:(BEMSimpleLineGraphView*)graph valueForPointAtIndex:(NSInteger)index
{
    SENTrendDataPoint* point;
    if (self.graphType == HEMTrendCellGraphTypeBar) {
        point = self.points[index];
    } else {
        point = self.points[MIN(MAX(0, index - 1), self.points.count - 1)];
    }
    return point.yValue;
}

#pragma mark BEMSimpleLineGraphDelegate

- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView*)graph
{
    return NO;
}

- (void)lineGraphDidBeginLoading:(BEMSimpleLineGraphView*)graph
{
    self.labeledIndexes = [NSMutableArray new];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView*)graph
{
    if ([self shouldShowGraphLabels]) {
        self.overlayView.hidden = NO;
        [self.overlayView layoutIfNeeded];
        NSArray* headers = [self sectionIndexValuesOfType:self.topLabelType];
        NSArray* footers = [self sectionIndexValuesOfType:self.bottomLabelType];
        if (self.bottomLabelType == HEMTrendCellGraphLabelTypeHourValue) {
            self.overlayView.bottomLabelColor = [UIColor lightTintColor];
        } else {
            self.overlayView.bottomLabelColor = [UIColor trendTextColor];
        }
        self.overlayView.bottomLabelFont = [UIFont trendBottomLabelFont];
        [self.overlayView setSectionFooters:footers headers:headers];
    }
    else {
        self.overlayView.hidden = YES;
    }
}

// Calculates number of gaps necessary to create preferred number of graph sections
- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView*)graph
{
    if (self.points.count == self.numberOfGraphSections) {
        return 0;
    }
    return self.points.count / (self.numberOfGraphSections + 1);
}

// @discussion
// Bypasses the built-in line graph utility for assigning labels to columns, but uses the
// labeled index calculation to cache which indexes to label. Skips line graph buffer points.
- (NSString*)lineGraph:(BEMSimpleLineGraphView*)graph labelOnXAxisForIndex:(NSInteger)index
{
    if (self.graphType == HEMTrendCellGraphTypeBar || (index < self.points.count)) {
        [self.labeledIndexes addObject:@(index)];
    }
    return @"";
}

- (BOOL)lineGraph:(BEMSimpleLineGraphView*)graph alwaysDisplayPopUpAtIndex:(CGFloat)index
{
    return index == self.maxIndex || index == self.minIndex;
}

- (UIColor*)lineGraph:(BEMSimpleLineGraphView*)graph colorForDotAtIndex:(NSInteger)index
{
    if ([self lineGraph:graph alwaysDisplayPopUpAtIndex:index]) {
        CGFloat value = [self lineGraph:graph valueForPointAtIndex:index];
        return [UIColor colorForSleepScore:(NSInteger)value];
    }
    return nil;
}

- (BOOL)lineGraph:(BEMSimpleLineGraphView*)graph alwaysDisplayDotAtIndex:(NSInteger)index
{
    return [self lineGraph:graph alwaysDisplayPopUpAtIndex:index];
}

- (UIColor*)lineGraph:(BEMSimpleLineGraphView*)graph colorForPopUpAtIndex:(NSInteger)index
{
    return [self lineGraph:graph colorForDotAtIndex:index];
}

@end
