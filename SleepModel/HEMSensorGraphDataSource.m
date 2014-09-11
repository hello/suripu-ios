
#import <SenseKit/SENSensor.h>

#import "HEMSensorGraphDataSource.h"
#import "HelloStyleKit.h"

@interface HEMSensorGraphDataSource ()

@property (nonatomic, strong, readwrite) NSArray* dataSeries;
@property (nonatomic, weak) SENSensor* sensor;
@end

@implementation HEMSensorGraphDataSource

- (instancetype)initWithDataSeries:(NSArray*)dataSeries
{
    if (self = [super init]) {
        _dataSeries = dataSeries;
    }
    return self;
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView*)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView*)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return self.dataSeries.count;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0)
        return [[self.dataSeries[horizontalIndex] valueForKey:@"value"] floatValue];

    return 0;
}

#pragma mark appearance

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView*)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0 ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView*)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView dotRadiusForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 8.f;
}

- (BOOL)lineChartView:(JBLineChartView*)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0)
        return 2.f;
    return 1.f;
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [HelloStyleKit mediumBlueColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [HelloStyleKit mediumBlueColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0 ? [HelloStyleKit lightBlueColor] : [UIColor clearColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView selectionColorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [HelloStyleKit darkBlueColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [HelloStyleKit mediumBlueColor];
}

#pragma mark selection appearance

- (CGFloat)verticalSelectionWidthForLineChartView:(JBLineChartView*)lineChartView
{
    return 4.f;
}

@end
