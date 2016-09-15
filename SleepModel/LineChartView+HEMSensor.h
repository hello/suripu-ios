//
//  LineChartView+HEMSensor.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>

@interface LineChartView (HEMSensor)

- (NSArray*)gradientColorsWithColor:(UIColor*)color;
- (instancetype)initForSensorWithFrame:(CGRect)frame;
- (UIColor*)lineColorForColor:(UIColor*)color;
- (void)animateIn;
- (void)fadeIn;

@end
