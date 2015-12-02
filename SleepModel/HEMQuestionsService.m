//
//  HEMQuestionsService.m
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAPIQuestions.h>

#import "HEMQuestionsService.h"
#import "HEMAppReview.h"

NSString* const HEMQuestionsServiceErrorDomain = @"is.hello.app.service.questions";

@interface HEMQuestionsService()

@property (nonnull, strong, nonatomic) NSArray<SENQuestion*>* questions;

@end

// TODO: move logic of answering app review questions here
@implementation HEMQuestionsService

- (nonnull NSError*)errorWithCode:(HEMQuestionsError)code {
    return [NSError errorWithDomain:HEMQuestionsServiceErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)refreshQuestions:(nonnull HEMInsightsFeedQuestionHandler)completion {
    __weak typeof(self) weakSelf = self;
    [HEMAppReview shouldAskUserToRateTheApp:^(HEMAppReviewQuestion *question) {
        if (question) {
            [SENAnalytics track:HEMAnalyticsEventAppReviewShown];
            
            NSArray<SENQuestion*>* questions = @[question];
            [weakSelf setQuestions:questions];
            completion (questions, nil);
        } else {
            [SENAPIQuestions getQuestionsFor:[NSDate date] completion:^(id data, NSError *error) {
                if (error) {
                    [SENAnalytics trackError:error];
                } else {
                    [weakSelf setQuestions:data];
                }
                completion (data, error);
            }];
        }
    }];
}

- (void)skipAppReviewQuestion:(nonnull HEMAppReviewQuestion*)question
                   completion:(nullable HEMInsightsFeedQuestionHandler)completion {
    [HEMAppReview markAppReviewPromptCompleted];
    [SENAnalytics track:HEMAnalyticsEventAppReviewSkip];
    if (completion) {
        completion (nil, nil);
    }
}

- (void)removeQuestionFromCache:(nonnull SENQuestion*)question {
    NSMutableArray* questions = [[self questions] mutableCopy];
    [questions removeObject:question];
    [self setQuestions:questions];
}

- (void)skipSleepQuestion:(nonnull SENQuestion*)question
               completion:(nullable HEMInsightsFeedQuestionHandler)completion {
    __block SENQuestion* questionToSkip = question;
    __weak typeof (self) weakSelf = self;
    
    [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf removeQuestionFromCache:questionToSkip];
        }
        
        if (completion) {
            completion ([strongSelf questions], error);
        }
    }];
}

- (void)skipQuestion:(nonnull SENQuestion*)question
          completion:(nullable HEMInsightsFeedQuestionHandler)completion {
    
    if ([question isKindOfClass:[HEMAppReviewQuestion class]]) {
        [self skipAppReviewQuestion:(id)question completion:completion];
    } else if ([question isKindOfClass:[SENQuestion class]]) {
        [self skipSleepQuestion:(id)question completion:completion];
    } else {
        if (completion) {
            completion ([self questions], [self errorWithCode:HEMQuestionsErrorUnsupported]);
        }
    }
    
}

- (void)answerSleepQuestion:(nonnull SENQuestion*)question
                withAnswers:(nonnull NSArray<SENAnswer*>*)answers
                 completion:(nullable HEMInsightsFeedQuestionHandler)completion {

    // Let the API to fail with callback if answer parameter is insuffcient
    __block SENQuestion* questionToUpdate = question;
    __weak typeof (self) weakSelf = self;
    [SENAPIQuestions sendAnswers:answers forQuestion:question completion:^(id data, NSError *error) {
        if (!error) {
            [weakSelf removeQuestionFromCache:questionToUpdate];
        } else {
            [SENAnalytics trackError:error];
        }
        
        if (completion) {
            completion ([weakSelf questions], error);
        }
    }];
    
}

@end
