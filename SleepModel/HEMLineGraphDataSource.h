
#import <Foundation/Foundation.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@class SENSensor;

@interface HEMLineGraphDataSource : NSObject <BEMSimpleLineGraphDataSource>

- (instancetype)initWithDataSeries:(NSArray*)dataSeries unit:(SENSensorUnit)unit;

- (NSArray*)valuesForSectionIndexes;

@property (nonatomic, strong, readonly) NSArray* dataSeries;
/**
 *  Formatter used for data point `datetime` formatting
 */
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@end
