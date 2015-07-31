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
    HEMAppReviewAnswerActionEnjoySense,
    HEMAppReviewAnswerActionDoNotEnjoySense,
    HEMAppReviewAnswerActionOpenSupport,
    HEMAppReviewAnswerActionSendFeedback,
    HEMAppReviewAnswerActionRateTheApp,
    HEMAppReviewAnswerActionStopAsking
};

@interface HEMAppReviewAnswer : SENAnswer

@property (nonatomic, assign, readonly) HEMAppReviewAnswerAction action;

/**
 * Initialize the instance with the text for the answer, the identifier for the
 * question that the answer is tied to, and the action that should be taken when
 * the answer is selected
 *
 * @param answer:     text to display
 * @param questionId: the identifier for the question
 * @param action:     action to take for this answer, when selected
 */
- (instancetype)initWithAnswer:(NSString*)answer
                    questionId:(NSNumber*)questionId
                        action:(HEMAppReviewAnswerAction)action;

@end
