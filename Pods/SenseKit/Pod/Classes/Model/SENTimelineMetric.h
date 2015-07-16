//
//  SENTimelineMetric.h
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import <Foundation/Foundation.h>
#import "SENCondition.h"
#import "SENSerializable.h"

typedef NS_ENUM(NSInteger, SENTimelineMetricType) {
    SENTimelineMetricTypeTotalDuration,
    SENTimelineMetricTypeSoundDuration,
    SENTimelineMetricTypeTimesAwake,
    SENTimelineMetricTypeFellAsleep,
    SENTimelineMetricTypeWokeUp,
    SENTimelineMetricTypeTimeToSleep,
    SENTimelineMetricTypeHumidity,
    SENTimelineMetricTypeLight,
    SENTimelineMetricTypeSound,
    SENTimelineMetricTypeTemperature,
    SENTimelineMetricTypeParticulates,
    SENTimelineMetricTypeUnknown
};

typedef NS_ENUM(NSInteger, SENTimelineMetricUnit) {
    SENTimelineMetricUnitMinute,
    SENTimelineMetricUnitQuantity,
    SENTimelineMetricUnitTimestamp,
    SENTimelineMetricUnitCondition,
    SENTimelineMetricUnitUnknown,
};

SENTimelineMetricType SENTimelineMetricTypeFromString(NSString* metricType);
SENTimelineMetricUnit SENTimelineMetricUnitFromString(NSString* metricUnit);

@interface SENTimelineMetric : NSObject <NSCoding, SENSerializable>

@property (nonatomic, strong) NSString* name;
@property (nonatomic) SENTimelineMetricType type;
@property (nonatomic) SENCondition condition;
@property (nonatomic) SENTimelineMetricUnit unit;
@property NSNumber* value;
@end