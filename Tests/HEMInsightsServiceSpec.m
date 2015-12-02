//
//  HEMInsightsServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import "HEMInsightsService.h"
#import "SENAnalytics+HEMAppAnalytics.h"

SPEC_BEGIN(HEMInsightsServiceSpec)

describe(@"HEMInsightsService", ^{
    
    __block HEMInsightsService* service;
    
    beforeEach(^{
        service = [HEMInsightsService new];
    });
    
    afterEach(^{
        service = nil;
    });
    
    describe(@"- getListOfInsightSummaries:", ^{
        
        context(@"api returned zero insights", ^{
            
            __block NSArray* insights = nil;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIInsight stub:@selector(getInsights:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (@[], nil);
                    return nil;
                }];
                
                [service getListOfInsightSummaries:^(NSArray<SENInsight *> * _Nullable data, NSError * _Nullable insightsError) {
                    insights = data;
                    error = insightsError;
                }];
            });
            
            afterEach(^{
                [SENAPIInsight clearStubs];
                insights = nil;
                error = nil;
            });
            
            it(@"should contain an empty list", ^{
                [[@([insights count]) should] equal:@(0)];
            });
            
            it(@"should not have returned an error", ^{
                [[error should] beNil];
            });
            
        });
        
        context(@"api returned an error", ^{
            
            __block NSArray* insights = nil;
            __block NSError* error = nil;
            __block BOOL trackedError = NO;
            
            beforeEach(^{
                [SENAPIInsight stub:@selector(getInsights:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAnalytics stub:@selector(trackError:) withBlock:^id(NSArray *params) {
                    trackedError = YES;
                    return nil;
                }];
                
                [service getListOfInsightSummaries:^(NSArray<SENInsight *> * _Nullable data, NSError * _Nullable insightsError) {
                    insights = data;
                    error = insightsError;
                }];
            });
            
            afterEach(^{
                [SENAnalytics clearStubs];
                [SENAPIInsight clearStubs];
                insights = nil;
                error = nil;
                trackedError = NO;
            });
            
            it(@"should not contain any insights", ^{
                [[insights should] beNil];
            });
            
            it(@"should have returned an error", ^{
                [[error should] beNonNil];
            });
            
            it(@"should have tracked the error", ^{
                [[@(trackedError) should] beYes];
            });
            
        });
        
        context(@"api returned 1 insight", ^{
            
            __block NSArray* insights = nil;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIInsight stub:@selector(getInsights:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (@[[SENInsight new]], nil);
                    return nil;
                }];
                
                [service getListOfInsightSummaries:^(NSArray<SENInsight *> * _Nullable data, NSError * _Nullable insightsError) {
                    insights = data;
                    error = insightsError;
                }];
            });
            
            afterEach(^{
                [SENAPIInsight clearStubs];
                insights = nil;
                error = nil;
            });
            
            it(@"should contain 1 insight", ^{
                id object = [insights firstObject];
                [[object should] beKindOfClass:[SENInsight class]];
            });
            
            it(@"should not have returned an error", ^{
                [[error should] beNil];
            });
            
        });
        
    });
    
});

SPEC_END
