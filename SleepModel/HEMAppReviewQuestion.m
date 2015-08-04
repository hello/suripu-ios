//
//  HEMAppReviewQuestion.m
//  Sense
//
//  Created by Jimmy Lu on 7/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAnswer.h>
#import "HEMAppReviewQuestion.h"
#import "HEMAppReviewAnswer.h"

@interface HEMAppReviewQuestion()

@property (nonatomic, strong) NSDictionary* conditionalQuestions;

@end

@implementation HEMAppReviewQuestion

+ (NSNumber*)questionIdForText:(NSString*)questionText {
    return @([questionText hash]);
}

- (instancetype)initQuestion:(NSString*)question
                     choices:(NSArray*)choices
        conditionalQuestions:(NSDictionary*)conditionalQuestions {

    NSNumber* questionId = [[self class] questionIdForText:question];
    self = [super initWithId:questionId
           questionAccountId:questionId
                    question:question
                        type:SENQuestionTypeChoice
                     choices:choices];
    
    if (self) {
        _conditionalQuestions = conditionalQuestions;
    }
    
    return self;
}

- (HEMAppReviewQuestion*)nextQuestionForAnswer:(HEMAppReviewAnswer*)answer {
    return [self conditionalQuestions][[answer answerId]];
}

@end
