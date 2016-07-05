//
//  HEMInsightsService.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENAPIInsight.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAppUnreadStats.h>
#import <SenseKit/SENService+Protected.h>

#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "HEMInsightsService.h"

static NSInteger const HEMInsightsImageCacheLimit = 5;

@interface HEMInsightsService()

@property (nonatomic, strong) NSCache* imageCache;

@end

@implementation HEMInsightsService

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageCache = [NSCache new];
        [_imageCache setCountLimit:HEMInsightsImageCacheLimit];
    }
    return self;
}

- (void)getListOfInsightSummaries:(nonnull HEMInsightSummariesHandler)completion {
    [SENAPIInsight getInsights:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (void)getInsightForSummary:(SENInsight*)insight completion:(HEMInsightHandler)completion {
    [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (BOOL)isGenericInsight:(SENInsight*)insight {
    return [insight type] == SENInsightTypeBasic;
}

#pragma mark - Service events

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [[self imageCache] removeAllObjects];
}

#pragma mark - Cache

- (id)cachedImageForUrl:(NSString*)insightImageUrl {
    return insightImageUrl ? [[self imageCache] objectForKey:insightImageUrl] : nil;
}

- (void)cacheImage:(id)image forInsightUrl:(NSString*)url {
    [[self imageCache] setObject:image forKey:url];
}

@end
