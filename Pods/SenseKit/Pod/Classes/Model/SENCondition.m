//
//  SENCondition.m
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>
#import "SENCondition.h"

NSString* const SENConditionRawUnavailable = @"UNAVAILABLE";
NSString* const SENConditionRawIdeal = @"IDEAL";
NSString* const SENConditionRawWarning = @"WARNING";
NSString* const SENConditionRawAlert = @"ALERT";

SENCondition SENConditionFromString(NSString *condition) {
    if ([condition isKindOfClass:[NSString class]]) {
        if ([condition isEqualToString:SENConditionRawIdeal])
            return SENConditionIdeal;
        else if ([condition isEqualToString:SENConditionRawAlert])
            return SENConditionAlert;
        else if ([condition isEqualToString:SENConditionRawWarning])
            return SENConditionWarning;
    }
    return SENConditionUnknown;
}