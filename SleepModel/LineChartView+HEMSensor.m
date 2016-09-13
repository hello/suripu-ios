//
//  LineChartView+HEMSensor.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "LineChartView+HEMSensor.h"

@implementation LineChartView (HEMSensor)

- (instancetype)initForSensorWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame]) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                                | UIViewAutoresizingFlexibleHeight];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setDrawGridBackgroundEnabled:NO];
        [self setDrawBordersEnabled:NO];
        [self setNoDataText:nil];
        [[self leftAxis] setEnabled:NO];
        [[self leftAxis] removeAllLimitLines];
        [[self rightAxis] removeAllLimitLines];
        [[self rightAxis] setEnabled:NO];
        [[self xAxis] setEnabled:NO];
        [[self xAxis] setDrawAxisLineEnabled:NO];
        [[self xAxis] setDrawGridLinesEnabled:NO];
        [[self xAxis] removeAllLimitLines];
        [self setDescriptionText:nil];
        [[self legend] setEnabled:NO];
        [[self layer] setBorderWidth:0.0f];
    }
    return self;
}

@end
