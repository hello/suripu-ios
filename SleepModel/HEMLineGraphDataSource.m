
#import <SenseKit/SENSensor.h>

#import "HEMLineGraphDataSource.h"
#import "HelloStyleKit.h"

@interface HEMLineGraphDataSource ()

@property (nonatomic, strong, readwrite) NSArray* dataSeries;
@property (nonatomic, strong) NSMutableSet* labeledIndexes;
@property (nonatomic) SENSensorUnit unit;
@end

@implementation HEMLineGraphDataSource

- (instancetype)initWithDataSeries:(NSArray*)dataSeries unit:(SENSensorUnit)unit
{
    if (self = [super init]) {
        _dataSeries = dataSeries;
        _labeledIndexes = [NSMutableSet new];
        _unit = unit;
    }
    return self;
}

- (NSArray*)valuesForSectionIndexes {
    NSMutableArray* labels = [[NSMutableArray alloc] initWithCapacity:self.labeledIndexes.count];
    NSArray* indexes = [[self.labeledIndexes allObjects] sortedArrayUsingSelector:@selector(compare:)];
    for (NSNumber* index in indexes) {
        SENSensorDataPoint* dataPoint = [self dataPointAtIndex:[index integerValue]];
        NSString* formattedValue = NSLocalizedString(@"empty-data", nil);
        if (dataPoint.value)
            formattedValue = [SENSensor formatValue:dataPoint.value withUnit:self.unit];
        [labels addObject:formattedValue];
    }
    return labels;
}

#pragma mark - BEMSimpleLineGraphDataSource

- (SENSensorDataPoint*)dataPointAtIndex:(NSInteger)index {
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
    CGFloat rawValue = [dataPoint.value floatValue];
    if (rawValue == 0)
        return rawValue;
    return [[SENSensor value:dataPoint.value inPreferredUnit:self.unit] floatValue];
}

@end
