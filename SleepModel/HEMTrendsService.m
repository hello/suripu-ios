//
//  HEMTrendsService.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENConditionRange.h>
#import <SenseKit/SENService+Protected.h>

#import "HEMTrendsService.h"
#import "HEMTrendsDisplayPoint.h"

static CGFloat const HEMTrendsServiceCacheExpirationInSecs = 300.0f;

@interface HEMTrendsService()

// caches required to prevent too uneccesary requests from being fired when data
// is rarely changed.  Expiration time interval can probably be higher.
@property (nonatomic, strong) NSCache* cachedTrendsByScale;
@property (nonatomic, strong) NSCache* cachedLastPullByScale;

@end

@implementation HEMTrendsService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setCachedTrendsByScale:[NSCache new]];
        [self setCachedLastPullByScale:[NSCache new]];
    }
    return self;
}

- (SENTrends*)cachedTrendsForTimeScale:(SENTrendsTimeScale)timeScale {
    if (timeScale == SENTrendsTimeScaleUnknown) {
        return nil;
    }
    
    SENTrends* cachedTrends = nil;
    NSNumber* timeScaleKey = @(timeScale);
    NSDate* lastPulled = [[self cachedLastPullByScale] objectForKey:timeScaleKey];
    BOOL expired = fabs([lastPulled timeIntervalSinceNow]) > HEMTrendsServiceCacheExpirationInSecs;
    if (expired) {
        [[self cachedTrendsByScale] removeObjectForKey:timeScaleKey];
    } else {
        cachedTrends = [[self cachedTrendsByScale] objectForKey:timeScaleKey];
    }
    return cachedTrends;
}

- (void)refreshTrendsFor:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion {
    SENTrends* cachedTrends = [self cachedTrendsForTimeScale:timeScale];
    if (cachedTrends) {
        completion (cachedTrends, timeScale, nil);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPITrends trendsForTimeScale:timeScale completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else if ([data isKindOfClass:[SENTrends class]]) {
            NSNumber* timeScaleKey = @(timeScale);
            [[strongSelf cachedTrendsByScale] setObject:data forKey:timeScaleKey];
            [[strongSelf cachedLastPullByScale] setObject:[NSDate date] forKey:timeScaleKey];
        }
        completion (data, timeScale, error);
    }];
}

- (void)sleepDepthLightPercentage:(CGFloat*)lightPercentage
                 mediumPercentage:(CGFloat*)mediumPercentage
                   deepPercentage:(CGFloat*)deepPercentage
                         forGraph:(SENTrendsGraph*)graph {
    if ([graph dataType] == SENTrendsDataTypePercent) {
        SENTrendsGraphSection* section = [[graph sections] firstObject];
        if ([[section values] count] == 3) {
            *lightPercentage = [[[section values] firstObject] CGFloatValue];
            *mediumPercentage = [[section values][1] CGFloatValue];
            *deepPercentage = [[[section values] lastObject] CGFloatValue];
        }
    }
}

- (SENCondition)conditionForValue:(NSNumber*)value inGraph:(SENTrendsGraph*)graph {
    NSArray<SENConditionRange*>* ranges = [graph conditionRanges];
    SENCondition condition = SENConditionUnknown;
    if (value) {
        for (SENConditionRange* range in ranges) {
            NSComparisonResult minResult = [value compare:[range minValue]];
            NSComparisonResult maxResult = [value compare:[range maxValue]];
            if ((minResult == NSOrderedDescending || minResult == NSOrderedSame)
                && (maxResult == NSOrderedAscending || maxResult == NSOrderedSame)) {
                condition = [range condition];
                break;
            }
        }
    }
    return condition;
}

- (NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)segmentedDataPointsFrom:(SENTrendsGraph*)graph {
    NSInteger sections = [[graph sections] count];
    NSMutableArray* displayPoints = [NSMutableArray arrayWithCapacity:sections];
    NSMutableArray* sectionOfPoints = nil;
    // FIXME: find a better way or possibly move this on the a bg thread
    for (SENTrendsGraphSection* section in [graph sections]) {
        sectionOfPoints = [NSMutableArray arrayWithCapacity:[[section values] count]];
        NSInteger index = 0;
        for (NSNumber* dataPoint in [section values]) {
            BOOL highlighted = [[section highlightedValues] containsObject:@(index)];
            HEMTrendsDisplayPoint* point = [[HEMTrendsDisplayPoint alloc] initWithValue:dataPoint
                                                                            highlighted:highlighted];
            [point setCondition:[self conditionForValue:dataPoint inGraph:graph]];
            [sectionOfPoints addObject:point];
            index++;
        }
        [displayPoints addObject:sectionOfPoints];
    }
    return displayPoints;
}

@end
