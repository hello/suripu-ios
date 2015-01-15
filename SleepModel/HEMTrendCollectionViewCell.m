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
#import "HEMBarGraphView.h"

@interface HEMTrendCollectionViewCell ()<HEMScopePickerViewDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSArray* points;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat min;
@end

@implementation HEMTrendCollectionViewCell

- (void)awakeFromNib
{
    self.scopePickerView.delegate = self;
    self.lineGraphView.dataSource = self;
    self.lineGraphView.delegate = self;
}

- (void)setTimeScopesWithOptions:(NSArray*)options
{
    [self.scopePickerView setButtonsWithTitles:options];
}

- (void)showLineGraphWithData:(NSArray*)points max:(CGFloat)max min:(CGFloat)min
{
    self.points = points;
    self.max = max;
    self.min = min;
    self.barGraphView.hidden = YES;
    self.lineGraphView.hidden = NO;
    [self.lineGraphView reloadGraph];
}

- (void)showBarGraphWithData:(NSArray*)points max:(CGFloat)max min:(CGFloat)min
{
    self.points = points;
    self.max = max;
    self.min = min;
    self.barGraphView.hidden = NO;
    self.lineGraphView.hidden = YES;
    [self.barGraphView setValues:points max:max min:min];
}

#pragma mark HEMScopePickerViewDelegate

- (void)didTapButtonWithText:(NSString *)text
{
    [self.delegate didTapTimeScopeButtonWithText:text];
}

#pragma mark BEMSimpleLineGraphDataSource

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.points.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    SENTrendDataPoint* point = self.points[index];
    return point.xValue;
}

#pragma mark BEMSimpleLineGraphDelegate

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.max;
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.min;
}

@end
