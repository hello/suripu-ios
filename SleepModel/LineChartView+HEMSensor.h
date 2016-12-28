//
//  LineChartView+HEMSensor.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>

@class HEMSensorValueFormatter;

@interface HEMSensorLimit : NSObject

@property(nonatomic, copy) NSString* min;
@property(nonatomic, copy) NSString* max;

+ (HEMSensorLimit*)limitWithMin:(NSString*)min max:(NSString*)max;

@end

@interface LineChartView (HEMSensor)

- (instancetype)initForSensorWithFrame:(CGRect)frame;
- (HEMSensorLimit*)limitFromCalculatedMinY:(NSNumber*)calculatedMinY
                            calculatedMaxY:(NSNumber*)calculatedMaxY
                                 formatter:(HEMSensorValueFormatter*)formatter;
- (void)animateIn;
- (void)fadeIn;

@end
