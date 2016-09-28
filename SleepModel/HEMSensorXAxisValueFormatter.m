//
//  HEMSensorXAxisValueFormatter.m
//  Sense
//
//  Created by Jimmy Lu on 9/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorXAxisValueFormatter.h"

@implementation HEMSensorXAxisValueFormatter

- (NSString*)stringForXValue:(NSInteger)index
                    original:(NSString*)original
             viewPortHandler:(ChartViewPortHandler*)viewPortHandler {
    return @"NOW";
}

@end
