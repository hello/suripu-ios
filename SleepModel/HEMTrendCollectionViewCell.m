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
#import "HelloStyleKit.h"
#import "HEMScopePickerView.h"
#import "HEMGraphSectionOverlayView.h"
#import "HEMBarGraphView.h"
#import "UIFont+HEMStyle.h"

@interface HEMTrendCollectionViewCell ()<HEMScopePickerViewDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat min;
@property (nonatomic, strong) NSMutableArray* labeledIndexes;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSDateFormatter* dayOfWeekFormatter;
@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@property (nonatomic, getter=isMaxValueVisible) BOOL maxVisible;
@property (nonatomic, getter=isMinValueVisible) BOOL minVisible;
@end

@implementation HEMTrendCollectionViewCell

- (void)awakeFromNib
{
    self.scopePickerView.delegate = self;
    self.overlayView.boldLastElement = NO;
    self.overlayView.showSeparatorLines = YES;
    self.topLabelType = HEMTrendCellGraphLabelTypeDate;
    self.bottomLabelType = HEMTrendCellGraphLabelTypeNone;
    self.numberOfGraphSections = 7;
    [self configureDateFormatters];
    [self configureLineGraphView];
}

- (void)configureDateFormatters
{
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"MMM d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEEEEE";
    self.monthFormatter = [NSDateFormatter new];
    self.monthFormatter.dateFormat = @"MMM";
}

- (void)configureLineGraphView
{
    self.lineGraphView.dataSource = self;
    self.lineGraphView.delegate = self;
    self.lineGraphView.colorTop = [UIColor clearColor];
    self.lineGraphView.colorLine = [[HelloStyleKit barButtonEnabledColor] colorWithAlphaComponent:0.4f];
    self.lineGraphView.colorBottom = [[HelloStyleKit barButtonEnabledColor] colorWithAlphaComponent:0.07f];
    self.lineGraphView.enableBezierCurve = YES;
    self.lineGraphView.alwaysDisplayPopUpLabels = YES;
    self.lineGraphView.colorBackgroundPopUplabel = [UIColor clearColor];
    self.lineGraphView.labelFont = [UIFont sensorGraphNumberFont];
    self.lineGraphView.colorPoint = [UIColor clearColor];
    self.lineGraphView.enableXAxisLabel = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.lineGraphView.hidden = YES;
    self.barGraphView.hidden = YES;
    self.overlayView.hidden = YES;
    [self.scopePickerView setButtonsWithTitles:nil selectedIndex:0];
    [self.overlayView setSectionFooters:nil headers:nil];
}

- (void)setTimeScopesWithOptions:(NSArray*)options selectedOptionIndex:(NSUInteger)selectedIndex
{
    [self.scopePickerView setButtonsWithTitles:options selectedIndex:selectedIndex];
}

- (void)showGraphOfType:(HEMTrendCellGraphType)type withData:(NSArray *)data
{
    self.maxVisible = NO;
    self.minVisible = NO;
    self.points = data;
    NSArray* values = [[data valueForKey:NSStringFromSelector(@selector(yValue))] sortedArrayUsingSelector:@selector(compare:)];
    self.max = [[values lastObject] floatValue];
    self.min = [[values firstObject] floatValue];
    BOOL showBarGraph = type == HEMTrendCellGraphTypeBar;
    BOOL showLineGraph = type == HEMTrendCellGraphTypeLine;
    if (HEMTrendCellGraphTypeNone)
        self.overlayView.hidden = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.barGraphView.alpha = showBarGraph ? 1 : 0;
        self.lineGraphView.alpha = showLineGraph ? 1 : 0;
    } completion:^(BOOL finished) {
        self.barGraphView.hidden = !showBarGraph;
        self.lineGraphView.hidden = !showLineGraph;
        if (showBarGraph) {
            [self.barGraphView layoutIfNeeded];
            [self.barGraphView setValues:data];
        } else if (showLineGraph) {
            [self.lineGraphView reloadGraph];
        }
    }];
}

- (NSArray*)sectionIndexValuesOfType:(HEMTrendCellGraphLabelType)type {
    NSMutableArray* labels = [[NSMutableArray alloc] initWithCapacity:self.labeledIndexes.count];
    NSArray* indexes = [self.labeledIndexes sortedArrayUsingSelector:@selector(compare:)];
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
            case HEMTrendCellGraphLabelTypeDayOfWeek:
                formattedValue = [self.dayOfWeekFormatter stringFromDate:dataPoint.date];
                break;
            case HEMTrendCellGraphLabelTypeMonth:
                formattedValue = [self.monthFormatter stringFromDate:dataPoint.date];
                break;
            case HEMTrendCellGraphLabelTypeNone:
            default:
                break;
        }
        if (formattedValue)
            [labels addObject:formattedValue];
    }
    return labels;
}

#pragma mark HEMScopePickerViewDelegate

- (void)didTapButtonWithText:(NSString *)text
{
    [self.delegate didTapTimeScopeInCell:self withText:text];
}

#pragma mark BEMSimpleLineGraphDataSource

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.points.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    SENTrendDataPoint* point = self.points[index];
    return point.yValue;
}

#pragma mark BEMSimpleLineGraphDelegate

- (void)lineGraphDidBeginLoading:(BEMSimpleLineGraphView *)graph
{
    self.labeledIndexes = [NSMutableArray new];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph
{
    if ([self shouldShowGraphLabels]) {
        self.overlayView.hidden = NO;
        [self.overlayView layoutIfNeeded];
        NSArray* headers = [self sectionIndexValuesOfType:self.topLabelType];
        NSArray* footers = [self sectionIndexValuesOfType:self.bottomLabelType];
        [self.overlayView setSectionFooters:footers headers:headers];
    } else {
        self.overlayView.hidden = YES;
    }
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.points.count/(self.numberOfGraphSections + 1);
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    [self.labeledIndexes addObject:@(index)];
    return @"";
}

- (BOOL)lineGraph:(BEMSimpleLineGraphView *)graph alwaysDisplayPopUpAtIndex:(CGFloat)index
{
    SENTrendDataPoint* point = self.points[(int)index];
    if (point.yValue == 0) {
        return NO;
    } else if (point.yValue == self.max) {
        if (![self isMaxValueVisible]) {
            self.maxVisible = YES;
            return YES;
        }
    } else if (point.yValue == self.min) {
        if (![self isMinValueVisible]) {
            self.minVisible = YES;
            return YES;
        }
    }
    return NO;
}

@end
