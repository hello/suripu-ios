
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
    if (self.dateFormatter) {
        NSArray* indexes = [[self.labeledIndexes allObjects] sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber* index in indexes) {
            NSDictionary* dataPoint = [self dataPointAtIndex:[index integerValue]];
            NSDate* lastUpdated = [NSDate dateWithTimeIntervalSince1970:([dataPoint[@"datetime"] doubleValue])/1000];
            [labels addObject:@{
                                [self.dateFormatter stringFromDate:lastUpdated]:[SENSensor formatValue:dataPoint[@"value"] withUnit:self.unit]}];
        }
    }
    return labels;
}

#pragma mark - BEMSimpleLineGraphDataSource

- (NSDictionary*)dataPointAtIndex:(NSInteger)index {
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
    NSDictionary* dataPoint = [self dataPointAtIndex:index];
    return [[SENSensor value:dataPoint[@"value"] inPreferredUnit:self.unit] floatValue];
}

@end
