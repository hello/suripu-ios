//
//  HEMAppReviewQuestion.h
//  Sense
//
//  Created by Jimmy Lu on 7/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENQuestion.h"

@class HEMAppReviewAnswer;

typedef NS_ENUM(NSUInteger, HEMAppReviewType) {
    HEMAppReviewTypeAppStore = 1,
    HEMAppReviewTypeAmazon
};

@interface HEMAppReviewQuestion : SENQuestion

@property (nonatomic, assign) HEMAppReviewType reviewType;

/**
 * Convenience method to determine the question identifier based on the question
 * text presented.
 *
 * @param questionText: the text for the question
 * @return              A numberical representation used as the question id
 */
+ (NSNumber*)questionIdForText:(NSString*)questionText;

/**
 * Initialize an app review question with the specified text, answers (choices)
 * and conditional questions that follow, based ont he answers.
 *
 * The conditional questions are used to determine the next quesetion based on
 * the answer selected.  The parameter is optional and will not be used if the
 * answers' actions do not require more questions to follow
 *
 * @param question:             text to show
 * @param choices:              answers to display for the question
 * @param conditionalQuestions: dictionary where keys are answer Id NSNumbers and
 *                              values are HEMAppReviewQuestion objects
 */
- (instancetype)initQuestion:(NSString*)question
                     choices:(NSArray*)choices
        conditionalQuestions:(NSDictionary*)conditionalQuestions;

/**
 * Determien the next app review question based on the answer selected for this
 * question object.
 * 
 * @param answer: the answer selected for this question
 * @return        question to ask based on the answer, if any
 */
- (HEMAppReviewQuestion*)nextQuestionForAnswer:(HEMAppReviewAnswer*)answer;

@end
