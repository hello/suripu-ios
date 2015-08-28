//
//  SENSensorAccessibility.m
//  Sense
//
//  Created by Delisa Mason on 8/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENSensorAccessibility.h"

NSString* SENConditionReadableValue(SENCondition condition) {
    switch (condition) {
        case SENConditionAlert:
            return NSLocalizedString(@"sensor.accessibility-value.condition-alert", nil);
        case SENConditionWarning:
            return NSLocalizedString(@"sensor.accessibility-value.condition-warning", nil);
        case SENConditionIdeal:
            return NSLocalizedString(@"sensor.accessibility-value.condition-ideal", nil);
        default:
            return NSLocalizedString(@"sensor.accessibility-value.condition-unknown", nil);
    }
}