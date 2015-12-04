//
//  HEMInsightsFeedService.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPIInsight.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAppUnreadStats.h>

#import "HEMInsightsFeedService.h"

@interface HEMInsightsFeedService()

@property (nonatomic, strong, nullable) NSArray<SENInsight*>* insights;

@end

@implementation HEMInsightsFeedService

- (void)refreshInsights:(nonnull HEMInsightsFeedInsightHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIInsight getInsights:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [weakSelf setInsights:data];
        }
        completion (data, error);
    }];
}

@end
