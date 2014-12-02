//
//  HEMSleepQuestionsDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENQuestion.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENServiceQuestions.h>

#import "HEMSleepQuestionsDataSource.h"

@interface HEMSleepQuestionsDataSource()

@property (nonatomic, strong) NSArray* questions;

@end

@implementation HEMSleepQuestionsDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self setSelectedQuestionIndex:0];
        [self setQuestions:[[SENServiceQuestions sharedService] todaysQuestions]];
    }
    return self;
}

- (SENQuestion*)selectedQuestion {
    SENQuestion* question = nil;
    if ([self selectedQuestionIndex] < [[self questions] count]) {
        question = [self questions][[self selectedQuestionIndex]];
    }
    return question;
}

- (NSString*)selectedQuestionText {
    SENQuestion* questionObject = [self selectedQuestion];
    return questionObject ? [questionObject question] : nil;
}

- (SENAnswer*)answerAtIndexPath:(NSIndexPath*)indexPath {
    SENAnswer* answer = nil;
    SENQuestion* questionObject = [self selectedQuestion];
    if ([indexPath row] < [[questionObject choices] count]) {
        answer = [questionObject choices][[indexPath row]];
    }
    return answer;
}

- (NSString*)answerTextAtIndexPath:(NSIndexPath*)indexPath {
    SENAnswer* answerObject = [self answerAtIndexPath:indexPath];
    return [answerObject answer];
}

- (BOOL)hasMoreQuestions {
    NSInteger nextQuestionIndex = [self selectedQuestionIndex] + 1;
    return nextQuestionIndex < [[self questions] count];
}

- (void)nextQuestion {
    [self setSelectedQuestionIndex:[self selectedQuestionIndex] + 1];
}

- (BOOL)skipQuestion {
    SENServiceQuestions* svc = [SENServiceQuestions sharedService];
    [svc skipQuestion:[self selectedQuestion] completion:nil];
    return [self hasMoreQuestions];
}

- (BOOL)selectAnswerAtIndexPath:(NSIndexPath*)indexPath {
    SENServiceQuestions* svc = [SENServiceQuestions sharedService];
    // per design, optimistically submit the answer as it's a better user experience
    // to proceed rather than wait for something that is not very important
    [svc submitAnswer:[self answerAtIndexPath:indexPath] completion:nil];
    return [self hasMoreQuestions];
}

- (NSInteger)numberOfAnswersForSelectedQuestion {
    SENQuestion* question = [self selectedQuestion];
    return [[question choices] count];
}

- (BOOL)isIndexPathLast:(NSIndexPath*)indexPath {
    return [indexPath row] == [self numberOfAnswersForSelectedQuestion] - 1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SENQuestion* question = [self selectedQuestion];
    return [[question choices] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"single";
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

@end
