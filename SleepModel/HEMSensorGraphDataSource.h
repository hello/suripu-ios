
#import <Foundation/Foundation.h>
#import <JBChartView/JBLineChartView.h>

@class SENSensor;

@interface HEMSensorGraphDataSource : NSObject <JBLineChartViewDataSource>

- (instancetype)initWithDataSeries:(NSArray*)dataSeries;

@property (nonatomic, strong, readonly) NSArray* dataSeries;
@end
