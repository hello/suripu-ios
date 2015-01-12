
#import <Foundation/Foundation.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@class SENSensor, SENSensorDataPoint;

@interface HEMLineGraphDataSource : NSObject <BEMSimpleLineGraphDataSource>

- (instancetype)initWithDataSeries:(NSArray*)dataSeries unit:(SENSensorUnit)unit;

- (NSArray*)valuesForSectionIndexes;
- (SENSensorDataPoint*)dataPointAtIndex:(NSInteger)index;

@property (nonatomic, strong, readonly) NSArray* dataSeries;
@end
