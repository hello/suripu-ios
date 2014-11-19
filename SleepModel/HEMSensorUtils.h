//
//  HEMSensorUtils.h
//  Sense
//
//  Created by Delisa Mason on 11/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenseKit/SENSensor.h>

@interface HEMSensorUtils : NSObject

+ (UIColor*)colorForSensorWithCondition:(SENSensorCondition)condition;
@end
