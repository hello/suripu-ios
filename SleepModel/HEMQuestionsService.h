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

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMInsightsFeedQuestionHandler)(NSArray<SENQuestion*>* _Nullable questions,
                                              NSError* _Nullable error);

@interface HEMQuestionsService : SENService

- (void)refreshQuestions:(HEMInsightsFeedQuestionHandler)completion;
- (void)skipQuestion:(SENQuestion*)question
          completion:(nullable HEMInsightsFeedQuestionHandler)completion;
- (void)answerSleepQuestion:(SENQuestion*)question
                withAnswers:(NSArray<SENAnswer*>*)answers
                 completion:(nullable HEMInsightsFeedQuestionHandler)completion;

@end

NS_ASSUME_NONNULL_END
