//
//  HEMQuestionsServiceSpec.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/API.h>
#import <SenseKit/Model.h>
#import "NSDate+HEMRelative.h"
#import "SENAnalytics+HEMAppAnalytics.h"
#import "HEMQuestionsService.h"
#import "HEMAppReview.h"

@interface HEMQuestionsService()

- (void)skipAppReviewQuestion:(nonnull HEMAppReviewQuestion*)question
                   completion:(nullable HEMInsightsFeedQuestionHandler)completion;
- (void)skipSleepQuestion:(nonnull SENQuestion*)question
               completion:(nullable HEMInsightsFeedQuestionHandler)completion;

@end

SPEC_BEGIN(HEMQuestionsServiceSpec)

describe(@"HEMQuestionsService", ^{
    
    __block HEMQuestionsService* service = nil;
    
    beforeEach(^{
        service = [HEMQuestionsService new];
    });
    
    afterEach(^{
        service = nil;
    });
    
    describe(@"-refreshQuestions:", ^{
        
        context(@"ask user to rate the app", ^{
            
            __block NSString* analyticsEvent = nil;
            __block NSArray* questionsReturned = nil;
            __block NSError* questionsError = nil;
            
            beforeEach(^{
                [HEMAppReview stub:@selector(shouldAskUserToRateTheApp:) withBlock:^id(NSArray *params) {
                    void(^cb)(HEMAppReviewQuestion* question) = [params lastObject];
                    cb ([HEMAppReviewQuestion new]);
                    return nil;
                }];
                
                [SENAnalytics stub:@selector(track:) withBlock:^id(NSArray *params) {
                    analyticsEvent = [params lastObject];
                    return nil;
                }];
                
                [service refreshQuestions:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    questionsReturned = questions;
                    questionsError = error;
                }];
                
            });
            
            afterEach(^{
                [HEMAppReview clearStubs];
                [SENAnalytics clearStubs];
                analyticsEvent = nil;
                questionsReturned = nil;
                questionsError = nil;
            });
            
            it(@"should not have returned an error", ^{
                [[questionsError should] beNil];
            });
            
            it(@"should have tracked an event about app review shown", ^{
                [[analyticsEvent should] equal:HEMAnalyticsEventAppReviewShown];
            });
            
            it(@"should return 1 app review question", ^{
                [[@([questionsReturned count]) should] equal:@1];
                [[[questionsReturned firstObject] should] beKindOfClass:[HEMAppReviewQuestion class]];
            });
            
        });
        
        context(@"regular sleep questions shown", ^{
            
            __block NSArray* questionsReturned = nil;
            __block NSError* questionsError = nil;
            __block NSDate* questionsDate = nil;
            
            beforeEach(^{
                [HEMAppReview stub:@selector(shouldAskUserToRateTheApp:) withBlock:^id(NSArray *params) {
                    void(^cb)(HEMAppReviewQuestion* question) = [params lastObject];
                    cb (nil);
                    return nil;
                }];
                
                [SENAPIQuestions stub:@selector(getQuestionsFor:completion:) withBlock:^id(NSArray *params) {
                    questionsDate = [params firstObject];
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[[SENQuestion new]], nil);
                    return nil;
                }];
                
                [service refreshQuestions:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    questionsReturned = questions;
                    questionsError = error;
                }];
                
            });
            
            afterEach(^{
                [HEMAppReview clearStubs];
                [SENAPIQuestions clearStubs];
                questionsReturned = nil;
                questionsError = nil;
                questionsDate = nil;
            });
            
            it(@"should not have returned an error", ^{
                [[questionsError should] beNil];
            });
            
            it(@"should return questions", ^{
                [[@([questionsReturned count]) shouldNot] equal:@0];
                [[[questionsReturned firstObject] should] beKindOfClass:[SENQuestion class]];
                [[[questionsReturned firstObject] shouldNot] beKindOfClass:[HEMAppReviewQuestion class]];
            });
            
            it(@"should have requested questions for toady", ^{
                [[@([questionsDate isOnSameDay:[NSDate date]]) should] beYes];
            });
            
        });
        
        context(@"app review question not shown, but error encountered with API", ^{
            
            __block NSArray* questionsReturned = nil;
            __block NSError* questionsError = nil;
            
            beforeEach(^{
                [HEMAppReview stub:@selector(shouldAskUserToRateTheApp:) withBlock:^id(NSArray *params) {
                    void(^cb)(HEMAppReviewQuestion* question) = [params lastObject];
                    cb (nil);
                    return nil;
                }];
                
                [SENAPIQuestions stub:@selector(getQuestionsFor:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [service refreshQuestions:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    questionsReturned = questions;
                    questionsError = error;
                }];
                
            });
            
            afterEach(^{
                [HEMAppReview clearStubs];
                [SENAPIQuestions clearStubs];
                questionsReturned = nil;
                questionsError = nil;
            });
            
            it(@"should have returned an error", ^{
                [[questionsError should] beNonNil];
            });
            
            it(@"should not return questions", ^{
                [[@([questionsReturned count]) should] equal:@0];
            });
            
        });
        
    });
    
    describe(@"-skipQuestion:completion", ^{
        
        context(@"skipping an app review question", ^{
           
            it(@"should call to skip app review question", ^{
                [[service should] receive:@selector(skipAppReviewQuestion:completion:)];
                [service skipQuestion:[HEMAppReviewQuestion new] completion:nil];
            });
            
            it(@"should make a call back", ^{
                __block BOOL calledBack = NO;
                [service skipQuestion:[HEMAppReviewQuestion new] completion:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    calledBack = YES;
                }];
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return any questions or error back", ^{
                __block NSArray* addlQuestions = nil;
                __block NSError* skipError = nil;
                [service skipQuestion:[HEMAppReviewQuestion new] completion:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    addlQuestions = questions;
                    skipError = error;
                }];
                
                [[addlQuestions should] beNil];
                [[skipError should] beNil];
            });
        });
        
        context(@"skipping a sleep question", ^{
            
            __block BOOL calledSkipSleepQuestion = NO;
            __block BOOL calledBack = NO;
            __block NSError* skipError = nil;
            
            beforeEach(^{
                [service stub:@selector(skipSleepQuestion:completion:) withBlock:^id(NSArray *params) {
                    calledSkipSleepQuestion = YES;
                    HEMInsightsFeedQuestionHandler cb = [params lastObject];
                    cb (@[[SENQuestion new]], nil);
                    return nil;
                }];
                
                [service skipQuestion:[SENQuestion new] completion:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                    calledBack = YES;
                    skipError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledSkipSleepQuestion = NO;
                calledBack = NO;
                skipError = nil;
            });
            
            it(@"should call to skip sleep question", ^{
                [[@(calledSkipSleepQuestion) should] beYes];
            });
            
            it(@"should make a call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return error", ^{
                [[skipError should] beNil];
            });
        });
        
    });
    
    describe(@"-answerSleepQuestion:withAnswers:completion:", ^{
        
        context(@"no error", ^{
            
            __block BOOL calledAPI = NO;
            __block BOOL trackedError = NO;
            __block BOOL calledBack = NO;
            __block NSError* skipError = nil;

            beforeEach(^{
                [SENAPIQuestions stub:@selector(sendAnswers:forQuestion:completion:) withBlock:^id(NSArray *params) {
                    calledAPI = YES;
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, nil);
                    return nil;
                }];
                
                [SENAnalytics stub:@selector(trackError:) withBlock:^id(NSArray *params) {
                    trackedError = YES;
                    return nil;
                }];
                
                [service answerSleepQuestion:[SENQuestion new]
                                 withAnswers:@[]
                                  completion:^(NSArray<SENQuestion *> * _Nullable questions, NSError * _Nullable error) {
                                      skipError = error;
                                      calledBack = YES;
                                  }];
            });
            
            afterEach(^{
                [SENAPIQuestions clearStubs];
                [SENAnalytics clearStubs];
                calledAPI = YES;
                trackedError = NO;
                calledBack = NO;
                skipError = nil;
            });
            
            it(@"should have called API", ^{
                [[@(calledAPI) should] beYes];
            });
            
            it(@"should not have tracked Error", ^{
                [[@(trackedError) should] beNo];
            });
            
            it(@"should called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have any error", ^{
                [[skipError should] beNil];
            });
            
        });
        
    });
    
});

SPEC_END
