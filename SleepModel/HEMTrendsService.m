//
//  HEMTrendsService.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENService+Protected.h>

#import "HEMTrendsService.h"

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
    if (!lastPulled || expired) {
        if (expired) {
            [[self cachedTrendsByScale] removeObjectForKey:timeScaleKey];
            DDLogVerbose(@"removing expired cached trends");
        } else {
            cachedTrends = [[self cachedTrendsByScale] objectForKey:timeScaleKey];
            DDLogVerbose(@"returning cached trends %@", cachedTrends);
        }
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

@end
