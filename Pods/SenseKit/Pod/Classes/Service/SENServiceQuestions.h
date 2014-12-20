//
//  SENServiceQuestions.h
//  Pods
//
//  A service that interacts with the SENAPIQuestions
//  and manage when sleep questions should be pulled
//  and shown to the users.
//
//  Created by Jimmy Lu on 9/10/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SENService.h"

@class SENAnswer;
@class SENQuestion;

typedef void(^SENServiceQuestionBlock)(NSArray* questions, NSError* error);

typedef NS_ENUM(NSUInteger, SENServiceQuestionsErrorCode) {
    SENServiceQuestionsErrorCodeUpdateInProgress = 1
};

@interface SENServiceQuestions : SENService

@property (nonatomic, copy, readonly) NSArray* todaysQuestions;

+ (id)sharedService;

/**
 * @return YES if currently checking for answers, NO otherwise
 */
- (BOOL)isUpdating;

/**
 * Update questions, if any.
 *
 * @param completion: called upon completion of updating questions.
 */
- (void)updateQuestions:(SENServiceQuestionBlock)completion;

/**
 * Submit an answer to this service.  Doing so will implicityly
 * set questions as asked for today
 * @param answer: the answer to submit
 * @param question: the question being answered
 * @param completion: the block to invoke when submission is complete
 */
- (void)submitAnswer:(SENAnswer*)answer
         forQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion;

/**
 * Submit multiple answers to the same question.  This is meant for questions
 * that allow multiple answers.
 *
 * @param answers: an array of SENAnswer objects
 * @param question: the question being answered
 * @param completion: the block to invoke when submission is complete
 */
- (void)submitAnswers:(NSArray*)answers
          forQuestion:(SENQuestion*)question
           completion:(void(^)(NSError* error))completion;

/**
 * Skip the question specified.
 *
 * @param question:   the question to skip
 * @param completion: the block to invoke when question has been skipped
 */
- (void)skipQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion;

@end