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

@interface HEMTrendsService()

@end

@implementation HEMTrendsService

- (void)refreshTrendsFor:(SENTrendsTimeScale)timeScale completion:(HEMTrendsServiceDataHandler)completion {
    [SENAPITrends trendsForTimeScale:timeScale completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

@end
