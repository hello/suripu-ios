//
//  SENCondition.h
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SENCondition) {
    SENConditionUnknown    = 0,
    SENConditionAlert      = 1,
    SENConditionWarning    = 2,
    SENConditionIdeal      = 3,
    SENConditionIncomplete = 4,
};

/**
 *  Identifies a matching condition from a value
 *
 *  @param value a condition format string, like 'ALERT'
 *
 *  @return the matching condition or SENSensorConditionUnknown
 */
SENCondition SENConditionFromString(NSString *condition);