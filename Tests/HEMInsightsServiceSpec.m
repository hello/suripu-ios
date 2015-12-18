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
    
    describe(@"- getListOfInsightSummaries:", ^{
        
        context(@"api returned an error", ^{
            
            __block SENInsightInfo* info = nil;
            __block NSError* error = nil;
            __block BOOL trackedError = NO;
            
            beforeEach(^{
                [SENAPIInsight stub:@selector(getInfoForInsight:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAnalytics stub:@selector(trackError:) withBlock:^id(NSArray *params) {
                    trackedError = YES;
                    return nil;
                }];
                
                [service getInsightForSummary:[SENInsight new] completion:^(SENInsightInfo* _Nullable data, NSError * _Nullable insightError) {
                    info = data;
                    error = insightError;
                }];
            });
            
            afterEach(^{
                [SENAnalytics clearStubs];
                [SENAPIInsight clearStubs];
                info = nil;
                error = nil;
                trackedError = NO;
            });
            
            it(@"should not return any data", ^{
                [[info should] beNil];
            });
            
            it(@"should have returned an error", ^{
                [[error should] beNonNil];
            });
            
            it(@"should have tracked the error", ^{
                [[@(trackedError) should] beYes];
            });
            
        });
        
        context(@"api returned the info with no error", ^{
            
            __block SENInsightInfo* info = nil;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIInsight stub:@selector(getInfoForInsight:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block ([SENInsightInfo new], nil);
                    return nil;
                }];
                
                [service getInsightForSummary:[SENInsight new] completion:^(SENInsightInfo * _Nullable insight, NSError * _Nullable insightError) {
                    info = insight;
                    error = insightError;
                }];
            });
            
            afterEach(^{
                [SENAPIInsight clearStubs];
                info = nil;
                error = nil;
            });
            
            it(@"should contain the info", ^{
                [[info should] beKindOfClass:[SENInsightInfo class]];
            });
            
            it(@"should not have returned an error", ^{
                [[error should] beNil];
            });
            
        });
        
    });
    
    describe(@"-isGenericInsight:", ^{
        
        it(@"should return YES if category is GENERIC", ^{
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"category" : @"GENERIC"}];
            BOOL generic = [service isGenericInsight:insight];
            [[@(generic) should] beYes];
        });
        
        it(@"should return YES if category is SLEEP_DURATION", ^{
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"category" : @"SLEEP_DURATION"}];
            BOOL generic = [service isGenericInsight:insight];
            [[@(generic) should] beYes];
        });
        
        it(@"should return YES if category is sleep_hygiene, lower case", ^{
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"category" : @"sleep_hygiene"}];
            BOOL generic = [service isGenericInsight:insight];
            [[@(generic) should] beYes];
        });
        
        it(@"should return NO if category is not one of the generic categories", ^{
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"category" : @"not_generic"}];
            BOOL generic = [service isGenericInsight:insight];
            [[@(generic) should] beNo];
        });
        
    });
    
});

SPEC_END
