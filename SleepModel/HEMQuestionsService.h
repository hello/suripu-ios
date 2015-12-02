//
//  HEMQuestionsService.h
//  Sense
//
//  Created by Jimmy Lu on 11/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"

@class SENQuestion;
@class SENAnswer;

extern NSString* _Nonnull const HEMQuestionsServiceErrorDomain;

typedef NS_ENUM(NSInteger, HEMQuestionsError) {
    HEMQuestionsErrorUnsupported = -1
};

typedef void(^HEMInsightsFeedQuestionHandler)(NSArray<SENQuestion*>* _Nullable questions,
                                              NSError* _Nullable error);

@interface HEMQuestionsService : SENService

- (void)refreshQuestions:(nonnull HEMInsightsFeedQuestionHandler)completion;
- (void)skipQuestion:(nonnull SENQuestion*)question
          completion:(nullable HEMInsightsFeedQuestionHandler)completion;
- (void)answerSleepQuestion:(nonnull SENQuestion*)question
                withAnswers:(nonnull NSArray<SENAnswer*>*)answers
                 completion:(nullable HEMInsightsFeedQuestionHandler)completion;

@end
