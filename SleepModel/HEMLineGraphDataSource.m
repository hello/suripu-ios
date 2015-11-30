
#import <SenseKit/SENSensor.h>

#import "HEMLineGraphDataSource.h"

@interface HEMLineGraphDataSource ()

@property (nonatomic, strong, readwrite) NSArray* dataSeries;
@property (nonatomic, strong) NSMutableSet* labeledIndexes;
@property (nonatomic) SENSensorUnit unit;
@end

@implementation HEMLineGraphDataSource

static CGFloat const HEMLineGraphMissingPoint = -200.f;

- (instancetype)initWithDataSeries:(NSArray*)dataSeries unit:(SENSensorUnit)unit
{
    if (self = [super init]) {
        _dataSeries = dataSeries;
        _labeledIndexes = [NSMutableSet new];
        _unit = unit;
    }
    return self;
}

#pragma mark - BEMSimpleLineGraphDataSource

- (SENSensorDataPoint*)dataPointAtIndex:(NSInteger)index {
    if (index >= self.dataSeries.count)
        return nil;
    return self.dataSeries[index];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.dataSeries.count;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    [_labeledIndexes addObject:@(index)];
    return @"";
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    SENSensorDataPoint* dataPoint = [self dataPointAtIndex:index];
    if (!dataPoint.value)
        return HEMLineGraphMissingPoint;
    return [[SENSensor value:dataPoint.value inPreferredUnit:self.unit] floatValue];
}

@end
