//
//  HEMSensorUtils.m
//  Sense
//
//  Created by Delisa Mason on 11/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSensorUtils.h"
#import "HelloStyleKit.h"

@implementation HEMSensorUtils

+ (UIColor *)colorForSensorWithCondition:(SENSensorCondition)condition {
    switch (condition) {
        case SENSensorConditionAlert:
            return [HelloStyleKit alertSensorColor];
        case SENSensorConditionWarning:
            return [HelloStyleKit warningSensorColor];
        case SENSensorConditionIdeal:
            return [HelloStyleKit idealSensorColor];
        default:
            return [HelloStyleKit backViewTextColor];
    }
}

@end
