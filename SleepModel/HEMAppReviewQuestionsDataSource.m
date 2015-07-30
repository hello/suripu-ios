//
//  HEMAppReviewQuestionsDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 7/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMAppReviewQuestionsDataSource.h"
#import "HEMAppReview.h"
#import "HEMZendeskService.h"
#import "HEMSettingsNavigationController.h"
#import "HEMSupportTopicsViewController.h"
#import "HEMMainStoryboard.h"

static NSString* const HEMQuestionCellIdSingle = @"single";
static NSString* const HEMAppReviewFeedbackTopic = @"feedback";

@interface HEMAppReviewQuestionsDataSource()

@property (nonatomic, strong) HEMAppReviewQuestion* currentReviewQuestion;
@property (nonatomic, strong) HEMAppReviewAnswer* selectedAnswer;
@property (nonatomic, weak)   UIViewController* controller;

@end

@implementation HEMAppReviewQuestionsDataSource

- (instancetype)initWithAppReviewQuestion:(HEMAppReviewQuestion*)appReviewQuestion {
    self = [super init];
    if (self) {
        _currentReviewQuestion = appReviewQuestion;
        [self configureZendesk];
    }
    return self;
}

- (void)configureZendesk {
    [[HEMZendeskService sharedService] configure:^(NSError *error) {
        if (error) {
            DDLogWarn(@"failed to configure zendesk with error %@", error);
            [SENAnalytics trackError:error];
        }
    }];
}

- (HEMAppReviewAnswer*)answerAtIndexPath:(NSIndexPath*)indexPath {
    NSArray* answers = [[self currentReviewQuestion] choices];
    HEMAppReviewAnswer* answer = nil;
    if ([indexPath row] < [answers count]) {
        answer = answers[[indexPath row]];
    }
    return answer;
}

- (NSString*)selectedQuestionText {
    return [[self currentReviewQuestion] text];
}

- (NSString*)answerTextAtIndexPath:(NSIndexPath*)indexPath {
    HEMAppReviewAnswer* answer = [self answerAtIndexPath:indexPath];
    return [answer answer];
}

/**
 * @discussion
 * App review questions are never multiple choice.
 */
- (BOOL)allowMultipleSelectionForSelectedQuestion {
    return NO;
}

- (void)nextQuestion {
    HEMAppReviewQuestion* next = [[self currentReviewQuestion] nextQuestionForAnswer:[self selectedAnswer]];
    [self setCurrentReviewQuestion:next];
}

/**
 * @discussion
 * Skipping the question is the same as if user declined to provide feedback or
 * write a review for the app and thus we should not need to proceed and should
 * mark as completed
 */
- (BOOL)skipQuestion {
    [HEMAppReview markAppReviewPromptCompleted];
    return NO;
}

- (BOOL)selectAnswerAtIndexPath:(NSIndexPath*)indexPath {
    HEMAppReviewAnswer* answer = [self answerAtIndexPath:indexPath];
    [self setSelectedAnswer:answer];
    return [answer action] == HEMAppReviewAnswerActionNextQuestion;
}

/**
 * @discussion
 * App review questions only support choice answers, not multi selection so set
 * should only contain 1 object
 */
- (BOOL)selectAnswersAtIndexPaths:(NSSet *)indexPaths {
    NSIndexPath* indexPath = [[indexPaths objectEnumerator] nextObject];
    return [self selectAnswerAtIndexPath:indexPath];
}

- (BOOL)isIndexPathLast:(NSIndexPath*)indexPath {
    NSArray* answers = [[self currentReviewQuestion] choices];
    return [indexPath row] == [answers count] - 1;
}

- (BOOL)takeActionBeforeDismissingFrom:(UIViewController*)controller {
    [HEMAppReview markAppReviewPromptCompleted];
    
    [self setController:controller];
    
    switch ([[self selectedAnswer] action]) {
        case HEMAppReviewAnswerActionOpenSupport:
            [self listenToTicketCreationEvents];
            [self launchSupportTopicPickerFrom:controller];
            return YES;
        case HEMAppReviewAnswerActionRateTheApp:
            [self listenToForAppComingBackToForeground];
            [HEMAppReview rateApp];
            return YES;
        case HEMAppReviewAnswerActionSendFeedback: {
            [self listenToTicketCreationEvents];
            [[HEMZendeskService sharedService] configureRequestWithTopic:HEMAppReviewFeedbackTopic completion:^{
                [ZDKRequests showRequestCreationWithNavController:[controller navigationController]];
            }];
            return YES;
        }
        case HEMAppReviewAnswerActionStopAsking:
            [HEMAppReview stopAskingToRateTheApp];
        case HEMAppReviewAnswerActionDone:
        default:
            return NO;
    }
}

- (void)launchSupportTopicPickerFrom:(UIViewController*)viewController {
    HEMSupportTopicsViewController* topics = [HEMMainStoryboard instantiateSupportTopicsViewController];
    [topics setModal:YES];
    
    HEMSettingsNavigationController* nav = [[HEMSettingsNavigationController alloc] initWithRootViewController:topics];
    [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)listenToForAppComingBackToForeground {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didComeBackToForeground)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
}

- (void)didComeBackToForeground {
    [[self controller] dismissViewControllerAnimated:YES completion:nil];
}

- (void)listenToTicketCreationEvents {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didCreateTicket)
                   name:ZDKAPI_RequestSubmissionSuccess
                 object:nil];
}

- (void)didCreateTicket {
    [[self controller] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self currentReviewQuestion] choices] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:HEMQuestionCellIdSingle];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
