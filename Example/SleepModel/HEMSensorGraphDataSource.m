
#import <SenseKit/SENSensor.h>

#import "HEMSensorGraphDataSource.h"

@interface HEMSensorGraphDataSource ()

@property (nonatomic, strong) NSArray* dataSeries;
@property (nonatomic, weak) SENSensor* sensor;
@end

@implementation HEMSensorGraphDataSource

- (instancetype)initWithDataSeries:(NSArray*)dataSeries forSensor:(SENSensor*)sensor
{
    if (self = [super init]) {
        _dataSeries = dataSeries;
        _sensor = sensor;
    }
    return self;
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView*)lineChartView
{
    return 2;
}

- (NSUInteger)lineChartView:(JBLineChartView*)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return self.dataSeries.count;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0)
        return [self.dataSeries[horizontalIndex] floatValue];

    return [self.sensor.valueInPreferredUnit floatValue];
}

#pragma mark appearance

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView*)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0 ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView*)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return NO;
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
    return [UIColor grayColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor grayColor];
}

#pragma mark selection appearance

- (CGFloat)verticalSelectionWidthForLineChartView:(JBLineChartView*)lineChartView
{
    return 2.f;
}

@end
