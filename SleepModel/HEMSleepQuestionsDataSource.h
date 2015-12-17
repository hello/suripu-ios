//
//  HEMSleepQuestionsDataSource.h
//  Sense
//
//  This is the data source for sleep questions.  It is intended to be reused
//  and passed to a view controller until all questions have been asked.
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMQuestionsDataSource.h"

@class SENQuestion;
@class HEMQuestionsService;

@interface HEMSleepQuestionsDataSource : NSObject <HEMQuestionsDataSource>

@property (nonatomic, assign) NSInteger selectedQuestionIndex;

- (nonnull instancetype)initWithQuestions:(nonnull NSArray<SENQuestion *> *)questions
                         questionsService:(nonnull HEMQuestionsService*)service;

@end
