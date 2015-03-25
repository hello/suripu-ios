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
#import "UIColor+HEMStyle.h"

@interface HEMTrendCollectionViewCell () <HEMScopePickerViewDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat min;
@property (nonatomic, strong) NSMutableArray* labeledIndexes;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSDateFormatter* dayOfWeekFormatter;
@property (nonatomic, strong) NSDateFormatter* monthFormatter;
@property (nonatomic, getter=isMaxValueVisible) NSUInteger maxIndex;
@property (nonatomic, getter=isMinValueVisible) NSUInteger minIndex;
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
    self.lineGraphView.dataSource = self;
    self.lineGraphView.delegate = self;
    self.lineGraphView.sizePoint = 5.f;
    self.lineGraphView.colorTop = [UIColor clearColor];
    self.lineGraphView.colorLine = [[HelloStyleKit tintColor] colorWithAlphaComponent:0.4f];
    self.lineGraphView.colorBottom = [[HelloStyleKit tintColor] colorWithAlphaComponent:0.07f];
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
    self.points = data;
    NSArray* values = [data valueForKey:NSStringFromSelector(@selector(yValue))];
    NSArray* sortedValues = [values sortedArrayUsingSelector:@selector(compare:)];
    NSNumber* max = [sortedValues lastObject];
    for (int i = 0; i < sortedValues.count; i++) {
        NSNumber* number = sortedValues[i];
        if ([number floatValue] > 0) {
            self.minIndex = [values indexOfObject:number];
            break;
        }
    }
    self.maxIndex = [values indexOfObject:max];
    BOOL showBarGraph = type == HEMTrendCellGraphTypeBar;
    BOOL showLineGraph = type == HEMTrendCellGraphTypeLine;
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
    switch (index) {
    case 0:
        return NSLocalizedString(@"trends.days.sunday.short", nil);
    case 1:
        return NSLocalizedString(@"trends.days.monday.short", nil);
    case 2:
        return NSLocalizedString(@"trends.days.tuesday.short", nil);
    case 3:
        return NSLocalizedString(@"trends.days.wednesday.short", nil);
    case 4:
        return NSLocalizedString(@"trends.days.thursday.short", nil);
    case 5:
        return NSLocalizedString(@"trends.days.friday.short", nil);
    case 6:
        return NSLocalizedString(@"trends.days.saturday.short", nil);
    default:
        return nil;
    }
}

#pragma mark HEMScopePickerViewDelegate

- (void)didTapButtonWithText:(NSString*)text
{
    [self.delegate didTapTimeScopeInCell:self withText:text];
}

#pragma mark BEMSimpleLineGraphDataSource

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView*)graph
{
    return self.points.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView*)graph valueForPointAtIndex:(NSInteger)index
{
    SENTrendDataPoint* point = self.points[index];
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
        [self.overlayView setSectionFooters:footers headers:headers];
    }
    else {
        self.overlayView.hidden = YES;
    }
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView*)graph
{
    return self.points.count / (self.numberOfGraphSections + 1);
}

- (NSString*)lineGraph:(BEMSimpleLineGraphView*)graph labelOnXAxisForIndex:(NSInteger)index
{
    [self.labeledIndexes addObject:@(index)];
    return @"";
}

- (BOOL)lineGraph:(BEMSimpleLineGraphView*)graph alwaysDisplayPopUpAtIndex:(CGFloat)index
{
    return index == self.maxIndex || index == self.minIndex;
}

- (UIColor*)lineGraph:(BEMSimpleLineGraphView*)graph colorForDotAtIndex:(NSInteger)index
{
    if (index == self.maxIndex || index == self.minIndex) {
        CGFloat value = [self lineGraph:graph valueForPointAtIndex:index];
        return [UIColor colorForSleepScore:(NSInteger)value];
    }
    return nil;
}

- (BOOL)lineGraph:(BEMSimpleLineGraphView*)graph alwaysDisplayDotAtIndex:(NSInteger)index
{
    return index == self.maxIndex || index == self.minIndex;
}

- (UIColor*)lineGraph:(BEMSimpleLineGraphView*)graph colorForPopUpAtIndex:(NSInteger)index
{
    return [self lineGraph:graph colorForDotAtIndex:index];
}

@end
