//
//  SENTrendsGraph.h
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//

#import <Foundation/Foundation.h>
#import "SENCondition.h"

@class SENConditionRange;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SENTrendsTimeScale) {
    SENTrendsTimeScaleUnknown = 0,
    SENTrendsTimeScaleWeek,
    SENTrendsTimeScaleMonth,
    SENTrendsTimeScaleQuarter
};

typedef NS_ENUM(NSInteger, SENTrendsDataType) {
    SENTrendsDataTypeUnknown = 0,
    SENTrendsDataTypeScore,
    SENTrendsDataTypeHour,
    SENTrendsDataTypePercent
};

typedef NS_ENUM(NSInteger, SENTrendsDisplayType) {
    SENTrendsDisplayTypeUnknown = 0,
    SENTrendsDisplayTypeGrid,
    SENTrendsDisplayTypeOverview,
    SENTrendsDisplayTypeBar,
    SENTrendsDisplayTypeBubble
};

SENTrendsDataType SENTrendsDataTypeFromString(id dataType);
SENTrendsTimeScale SENTrendsTimeScaleFromString(id timeScale);
NSString* SENTrendsTimeScaleValueFromEnum(SENTrendsTimeScale timeScale);

@interface SENTrendsGraphSection : NSObject

@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber*>* values;
@property (nonatomic, strong, readonly, nullable) NSArray<NSString*>* titles;
@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber*>* highlightedValues;
@property (nonatomic, strong, readonly, nullable) NSNumber* highlightedTitleIndex;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENTrendsAnnotation : NSObject

@property (nonatomic, copy, readonly, nullable) NSString* title;
@property (nonatomic, strong, readonly, nullable) NSNumber* value;
@property (nonatomic, assign, readonly) SENTrendsDataType dataType;
@property (nonatomic, assign, readonly) SENCondition condition;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENTrendsGraph : NSObject

@property (nonatomic, assign, readonly) SENTrendsTimeScale timeScale;
@property (nonatomic, assign, readonly) SENTrendsDataType dataType;
@property (nonatomic, assign, readonly) SENTrendsDisplayType displayType;
@property (nonatomic, copy, readonly, nullable)   NSString* title;
@property (nonatomic, strong, readonly, nullable) NSNumber* minValue;
@property (nonatomic, strong, readonly, nullable) NSNumber* maxValue;
@property (nonatomic, strong, readonly, nullable) NSArray<SENConditionRange*>* conditionRanges;
@property (nonatomic, strong, readonly, nullable) NSArray<SENTrendsGraphSection*>* sections;
@property (nonatomic, strong, readonly, nullable) NSArray<SENTrendsAnnotation*>* annotations;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END