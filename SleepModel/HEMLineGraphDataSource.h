
#import <Foundation/Foundation.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@class SENSensor;

@interface HEMLineGraphDataSource : NSObject <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

- (instancetype)initWithDataSeries:(NSArray*)dataSeries numberOfSections:(NSUInteger)sectionCount;

@property (nonatomic, strong, readonly) NSArray* dataSeries;
/**
 *  Formatter used for data point `datetime` formatting
 */
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@end
