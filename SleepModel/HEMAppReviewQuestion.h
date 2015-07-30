//
//  HEMAppReviewQuestion.h
//  Sense
//
//  Created by Jimmy Lu on 7/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "SENQuestion.h"

@class HEMAppReviewAnswer;

@interface HEMAppReviewQuestion : SENQuestion

+ (NSNumber*)questionIdForText:(NSString*)questionText;

- (instancetype)initQuestion:(NSString*)question
                     choices:(NSArray*)choices
        conditionalQuestions:(NSDictionary*)conditionalQuestions;

- (HEMAppReviewQuestion*)nextQuestionForAnswer:(HEMAppReviewAnswer*)answer;

@end
