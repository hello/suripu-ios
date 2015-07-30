//
//  HEMAppReviewAnswer.h
//  Sense
//
//  Created by Jimmy Lu on 7/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENAnswer.h"

typedef NS_ENUM(NSUInteger, HEMAppReviewAnswerAction) {
    HEMAppReviewAnswerActionDone,
    HEMAppReviewAnswerActionNextQuestion,
    HEMAppReviewAnswerActionOpenSupport,
    HEMAppReviewAnswerActionSendFeedback,
    HEMAppReviewAnswerActionRateTheApp,
    HEMAppReviewAnswerActionStopAsking
};

@interface HEMAppReviewAnswer : SENAnswer

@property (nonatomic, assign, readonly) HEMAppReviewAnswerAction action;

- (instancetype)initWithAnswer:(NSString*)answer
                    questionId:(NSNumber*)questionId
                        action:(HEMAppReviewAnswerAction)action;

@end
