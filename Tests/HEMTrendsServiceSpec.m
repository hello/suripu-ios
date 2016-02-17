//
//  HEMTrendsServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 2/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENConditionRange.h>
#import "HEMTrendsService.h"
#import "NSDate+HEMRelative.h"

@interface HEMTrendsService()

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, SENTrends*>* cachedTrendsByScale;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSDate*>* cachedLastPullByScale;

@end

SPEC_BEGIN(HEMTrendsServiceSpec)

describe(@"HEMTrendsService", ^{
    
    describe(@"-isReturningUser:", ^{
        
        context(@"available time scales returned, but no graphs", ^{
            
            __block SENTrends* trends = nil;
            __block NSArray<NSNumber*>* timeScales;
            __block BOOL returning = NO;
            
            beforeEach(^{
                trends = [SENTrends new];
                timeScales = @[@1, @2];
                [trends stub:@selector(availableTimeScales) andReturn:timeScales];
                
                HEMTrendsService* service = [HEMTrendsService new];
                returning = [service isReturningUser:trends];
            });
            
            afterEach(^{
                trends = nil;
                timeScales = nil;
                returning = YES;
            });
            
            it(@"should return YES", ^{
                [[@(returning) should] beYes];
            });
            
        });
        
        context(@"no trends", ^{
            
            __block BOOL returning = NO;
            
            beforeEach(^{
                HEMTrendsService* service = [HEMTrendsService new];
                returning = [service isReturningUser:nil];
            });
            
            afterEach(^{
                returning = YES;
            });
            
            it(@"should return NO", ^{
                [[@(returning) should] beNo];
            });
            
        });
        
    });
    
    describe(@"-daysUntilMoreTrends:", ^{
        
        context(@"there are more than 1 available time scales", ^{
            
            __block HEMTrendsService* service = nil;
            __block SENTrends* trends = nil;
            __block NSArray<NSNumber*>* timeScales;
            __block NSInteger daysToMore = 7;
            
            beforeEach(^{
                service = [HEMTrendsService new];
                timeScales = @[@1, @2];
                trends = [SENTrends new];
                [trends stub:@selector(availableTimeScales) andReturn:timeScales];
                daysToMore = [service daysUntilMoreTrends:trends];
            });
            
            afterEach(^{
                service = nil;
                trends = nil;
                daysToMore = 7;
            });
            
            it(@"should return 0", ^{
                [[@(daysToMore) should] equal:@0];
            });
            
        });
        
        context(@"no trends", ^{
            
            __block HEMTrendsService* service = nil;
            __block NSInteger daysToMore = 0;
            
            beforeEach(^{
                service = [HEMTrendsService new];
                daysToMore = [service daysUntilMoreTrends:nil];
            });
            
            afterEach(^{
                service = nil;
                daysToMore = 0;
            });
            
            it(@"should return 7", ^{
                [[@(daysToMore) should] equal:@7];
            });
            
        });
        
        context(@"trends with no available time scales and 1 day of data", ^{
            
            __block HEMTrendsService* service = nil;
            __block SENTrends* trends = nil;
            __block SENTrendsGraph* graph = nil;
            __block SENTrendsGraphSection* section = nil;
            __block NSInteger daysToMore = 0;
            
            beforeEach(^{
                service = [HEMTrendsService new];
                trends = [SENTrends new];
                graph = [SENTrendsGraph new];
                section = [SENTrendsGraphSection new];
                [section stub:@selector(values) andReturn:@[@1]];
                [graph stub:@selector(sections) andReturn:@[section]];
                [trends stub:@selector(graphs) andReturn:@[graph]];
                daysToMore = [service daysUntilMoreTrends:trends];
            });
            
            afterEach(^{
                service = nil;
                trends = nil;
                graph = nil;
                section = nil;
                daysToMore = 0;
            });
            
            it(@"should return 6", ^{
                [[@(daysToMore) should] equal:@6];
            });
            
        });
        
    });
    
    describe(@"-conditionForValue:inGraph:", ^{
        
        __block NSDictionary* alertScoreRange = nil;
        __block NSDictionary* warnScoreRange = nil;
        __block NSDictionary* idealScoreRange = nil;
        
        beforeEach(^{
            alertScoreRange = @{@"condition" : @"ALERT",
                                @"max_value" : @59,
                                @"min_value" : @0};
            warnScoreRange = @{@"condition" : @"WARNING",
                               @"max_value" : @79,
                               @"min_value" : @60};
            idealScoreRange = @{@"condition" : @"IDEAL",
                                @"max_value" : @100,
                                @"min_value" : @80};
        });
        
        afterEach(^{
            alertScoreRange = nil;
            warnScoreRange = nil;
            idealScoreRange = nil;
        });
        
        context(@"sleep score value is 79", ^{
            
            __block HEMTrendsService* service = nil;
            __block SENTrendsGraph* graph = nil;
            __block NSArray<SENConditionRange*>* ranges = nil;
            __block SENCondition condition = SENConditionUnknown;
            
            beforeEach(^{
                service = [HEMTrendsService new];
                graph = [SENTrendsGraph new];
                ranges = @[[[SENConditionRange alloc] initWithDictionary:alertScoreRange],
                           [[SENConditionRange alloc] initWithDictionary:warnScoreRange],
                           [[SENConditionRange alloc] initWithDictionary:idealScoreRange]];
                [graph stub:@selector(conditionRanges) andReturn:ranges];
                condition = [service conditionForValue:@79 inGraph:graph];
            });
            
            afterEach(^{
                service = nil;
                graph = nil;
                ranges = nil;
            });
            
            it(@"should return warning condition", ^{
                [[@(condition) should] equal:@(SENConditionWarning)];
            });
            
        });
        
    });
    
    describe(@"-refreshTrendsFor:completion:", ^{
        
        __block HEMTrendsService* service = nil;
        __block id response = nil;
        __block NSError* apiError = nil;
        __block SENTrendsTimeScale timeScaleReturned = SENTrendsTimeScaleUnknown;
        __block SENTrendsTimeScale timeScaleRequested = SENTrendsTimeScaleUnknown;
        
        context(@"no cache found, API returns trends", ^{
            
            beforeEach(^{
                service = [HEMTrendsService new];
                [service stub:@selector(cachedTrendsForTimeScale:) andReturn:nil];
                
                [SENAPITrends stub:@selector(trendsForTimeScale:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb ([SENTrends new], nil);
                    return nil;
                }];
                
                timeScaleRequested = SENTrendsTimeScaleWeek;
                
                [service refreshTrendsFor:timeScaleRequested completion:^(SENTrends * _Nullable trends, SENTrendsTimeScale scale, NSError * _Nullable error) {
                    response = trends;
                    apiError = error;
                    timeScaleReturned = scale;
                }];
                
            });
            
            afterEach(^{
                [SENAPITrends clearStubs];
                service = nil;
                response = nil;
                apiError = nil;
                timeScaleReturned = SENTrendsTimeScaleUnknown;
                timeScaleRequested = SENTrendsTimeScaleUnknown;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a trends object", ^{
                [[response should] beKindOfClass:[SENTrends class]];
            });
            
            it(@"should return same time scale as requsted", ^{
                [[@(timeScaleReturned) should] equal:@(timeScaleRequested)];
            });
            
            it(@"should have cached trends for scale", ^{
                [[[[service cachedTrendsByScale] objectForKey:@(timeScaleRequested)] should] beNonNil];
            });
            
            it(@"should have recorded last pulled date", ^{
                [[[[service cachedLastPullByScale] objectForKey:@(timeScaleRequested)] should] beKindOfClass:[NSDate class]];
            });
            
        });
        
        context(@"no cache found, API returns error", ^{
            
            beforeEach(^{
                service = [HEMTrendsService new];
                [service stub:@selector(cachedTrendsForTimeScale:) andReturn:nil];
                
                [SENAPITrends stub:@selector(trendsForTimeScale:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                timeScaleRequested = SENTrendsTimeScaleWeek;
                
                [service refreshTrendsFor:timeScaleRequested completion:^(SENTrends * _Nullable trends, SENTrendsTimeScale scale, NSError * _Nullable error) {
                    response = trends;
                    apiError = error;
                    timeScaleReturned = scale;
                }];
                
            });
            
            afterEach(^{
                [SENAPITrends clearStubs];
                service = nil;
                response = nil;
                apiError = nil;
                timeScaleReturned = SENTrendsTimeScaleUnknown;
                timeScaleRequested = SENTrendsTimeScaleUnknown;
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
            it(@"should not return a trends object", ^{
                [[response should] beNil];
            });
            
            it(@"should return same time scale as requsted", ^{
                [[@(timeScaleReturned) should] equal:@(timeScaleRequested)];
            });
            
            it(@"should not have cached trends for scale", ^{
                [[[[service cachedTrendsByScale] objectForKey:@(timeScaleRequested)] should] beNil];
            });
            
            it(@"should not have recorded last pulled date", ^{
                [[[[service cachedLastPullByScale] objectForKey:@(timeScaleRequested)] should] beNil];
            });
            
        });
        
        context(@"cache found", ^{
            
            __block SENTrends* trends = nil;
            __block BOOL calledAPI = NO;
            
            beforeEach(^{
                trends = [SENTrends new];
                service = [HEMTrendsService new];
                [service stub:@selector(cachedTrendsForTimeScale:) andReturn:trends];
                
                [SENAPITrends stub:@selector(trendsForTimeScale:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    calledAPI = YES;
                    cb ([SENTrends new], nil);
                    return nil;
                }];
                
                timeScaleRequested = SENTrendsTimeScaleWeek;
                
                [service refreshTrendsFor:timeScaleRequested completion:^(SENTrends * _Nullable trends, SENTrendsTimeScale scale, NSError * _Nullable error) {
                    response = trends;
                    apiError = error;
                    timeScaleReturned = scale;
                }];
                
            });
            
            afterEach(^{
                [SENAPITrends clearStubs];
                service = nil;
                response = nil;
                apiError = nil;
                calledAPI = NO;
                trends = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return cached trends", ^{
                [[response should] beNonNil];
            });
            
            it(@"should return same time scale as requsted", ^{
                [[@(timeScaleReturned) should] equal:@(timeScaleRequested)];
            });
            
            it(@"should not have called API", ^{
                [[@(calledAPI) should] beNo];
            });
            
        });
        
    });
    
});

SPEC_END
