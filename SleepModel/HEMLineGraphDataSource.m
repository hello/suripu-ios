
#import <SenseKit/SENSensor.h>

#import "HEMLineGraphDataSource.h"
#import "HelloStyleKit.h"

@interface HEMLineGraphDataSource ()

@property (nonatomic, strong, readwrite) NSArray* dataSeries;
@property (nonatomic) NSUInteger sectionCount;
@property (nonatomic, weak) SENSensor* sensor;
@end

@implementation HEMLineGraphDataSource

- (instancetype)initWithDataSeries:(NSArray*)dataSeries numberOfSections:(NSUInteger)sectionCount
{
    if (self = [super init]) {
        _dataSeries = dataSeries;
        _sectionCount = sectionCount;
    }
    return self;
}

#pragma mark - BEMSimpleLineGraphDelegate

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.dataSeries.count;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return ceil(self.dataSeries.count/self.sectionCount);
}

#pragma mark - BEMSimpleLineGraphDataSource

- (NSDictionary*)dataPointAtIndex:(NSInteger)index {
    return self.dataSeries[index];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    NSDictionary* dataPoint = [self dataPointAtIndex:index];
    CGFloat value = [dataPoint[@"value"] floatValue];
    if (value == 0)
        return @"-";

    if (self.dateFormatter) {
        NSDate* lastUpdated = [NSDate dateWithTimeIntervalSince1970:([dataPoint[@"datetime"] doubleValue])/1000];
        NSString* dateString = [self.dateFormatter stringFromDate:lastUpdated];
        return [NSString stringWithFormat:@"%f\n%@", value, dateString];
    }
    return [NSString stringWithFormat:@"%f", value];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSDictionary* dataPoint = [self dataPointAtIndex:index];
    return [dataPoint[@"value"] floatValue];
}

@end
