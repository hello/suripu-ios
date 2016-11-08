//
//  SENCondition.h
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SENCondition) {
    SENConditionUnknown = 0,
    SENConditionAlert,
    SENConditionWarning,
    SENConditionIdeal,
    SENConditionIncomplete,
    SENConditionCalibrating
};

/**
 *  Identifies a matching condition from a value
 *
 *  @param value a condition format string, like 'ALERT'
 *
 *  @return the matching condition or SENSensorConditionUnknown
 */
SENCondition SENConditionFromString(NSString *condition);