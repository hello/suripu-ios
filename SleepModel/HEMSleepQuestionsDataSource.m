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

static NSString* const HEMSleepQuestionCellIdSingle = @"single";
static NSString* const HEMSleepQuestionCellIdMulti = @"multiple";

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

- (BOOL)allowMultipleSelectionForSelectedQuestion {
    SENQuestion* questionObj = [self selectedQuestion];
    return [questionObj type] == SENQuestionTypeCheckbox;
}

- (NSString*)selectedQuestionText {
    SENQuestion* questionObject = [self selectedQuestion];
    return questionObject ? [questionObject text] : nil;
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
    [svc submitAnswer:[self answerAtIndexPath:indexPath]
          forQuestion:[self selectedQuestion]
           completion:nil];
    return [self hasMoreQuestions];
}

- (BOOL)selectAnswersAtIndexPaths:(NSSet*)indexPaths {
    DDLogVerbose(@"selected %ld answers by paths", [indexPaths count]);
    SENServiceQuestions* svc = [SENServiceQuestions sharedService];
    NSMutableArray* answers = [NSMutableArray arrayWithCapacity:[indexPaths count]];
    for (NSIndexPath* path in indexPaths) {
        SENAnswer* answer = [self answerAtIndexPath:path];
        if (answer) {
            [answers addObject:answer];
        }
    }
    
    SENQuestion* question = [self selectedQuestion];
    DDLogVerbose(@"submitting %ld answers to question %@", [answers count], [question text]);
    // per design, optimistically submit the answer as it's a better user experience
    // to proceed rather than wait for something that is not very important
    [svc submitAnswers:answers forQuestion:question completion:nil];
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
    SENQuestion* question = [self selectedQuestion];
    NSString* cellId = nil;
    switch ([question type]) {
        case SENQuestionTypeCheckbox:
            cellId = HEMSleepQuestionCellIdMulti;
            break;
        default:
            cellId = HEMSleepQuestionCellIdSingle;
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

@end
