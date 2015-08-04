//
//  HEMAppReviewAnswer.m
//  Sense
//
//  Created by Jimmy Lu on 7/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMAppReviewAnswer.h"

@interface HEMAppReviewAnswer()

@property (nonatomic, assign) HEMAppReviewAnswerAction action;

@end

@implementation HEMAppReviewAnswer

- (instancetype)initWithAnswer:(NSString*)answer
                    questionId:(NSNumber*)questionId
                        action:(HEMAppReviewAnswerAction)action {
    
    NSNumber* ansId = @([answer hash]);
    self = [super initWithId:ansId answer:answer questionId:questionId];
    if (self) {
        _action = action;
    }
    return self;
}

@end
