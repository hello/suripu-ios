
#import <Foundation/Foundation.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@class SENSensor, SENSensorDataPoint;

@interface HEMLineGraphDataSource : NSObject <BEMSimpleLineGraphDataSource>

- (instancetype)initWithDataSeries:(NSArray*)dataSeries unit:(SENSensorUnit)unit;

- (NSArray*)valuesForSectionIndexes;

- (SENSensorDataPoint*)dataPointAtIndex:(NSInteger)index;

/**
 *  Whether a value of zero is valid for a particular data type or indicates missing data
 *
 *  @return YES if a zero can occur with a given data type
 */
- (BOOL)canHaveZeroValue;

@property (nonatomic, strong, readonly) NSArray* dataSeries;
@end
