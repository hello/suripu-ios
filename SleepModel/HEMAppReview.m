//
//  HEMAppReview.m
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMAppReview.h"
#import "HEMAppUsage.h"
#import "HEMAlertViewController.h"
#import "NSDate+HEMRelative.h"
#import "HEMConfig.h"
#import "HEMAppReviewQuestion.h"
#import "HEMAppReviewAnswer.h"

@implementation HEMAppReview

NSUInteger const HEMAppPromptReviewThreshold = 60;
NSUInteger const HEMMinimumAppLaunches = 4;
NSUInteger const HEMSystemAlertShownThreshold = 30;
NSUInteger const HEMMinimumTimelineViews = 10;
NSString* const HEMNoMoreAsking = @"stop.asking.to.rate.app";

#pragma mark - Conditions for app review

+ (void)shouldAskUserToRateTheApp:(void(^)(HEMAppReviewQuestion* question))completion {
    if (!completion) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL meetsInitialRequirements
            = ![self hasStatedToStopAsking]
            && [self hasAppReviewURL]
            && [self hasNotYetReviewedThisVersion]
            && [self isWithinAppReviewThreshold]
            && [self meetsMinimumRequiredAppLaunches]
            && [self meetsMinimumRequiredTimelineViews]
            && [self isWithinSystemAlertThreshold];
        
        if (meetsInitialRequirements) {
            [self hasSenseAndPillPaired:^(BOOL hasPairedDevices) {
                HEMAppReviewQuestion* question = nil;
                if (hasPairedDevices) {
                    question = [self appReviewQuestion];
                }
                completion (question);
            }];
        } else {
            completion (nil);
        }
    });
}

+ (void)hasSenseAndPillPaired:(void(^)(BOOL hasPairedDevices))completion {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    [deviceService loadDeviceInfo:^(NSError *error) {
        completion (error == nil && [deviceService senseInfo] && [deviceService pillInfo]);
    }];
}

+ (BOOL)hasAppReviewURL {
    NSString* url = [HEMConfig stringForConfig:HEMConfAppReviewURL];
    return url != nil;
}

+ (BOOL)isWithinAppReviewThreshold {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
    NSDate* lastUpdated = [appUsage updated];
    return !lastUpdated || [lastUpdated daysElapsed] > HEMAppPromptReviewThreshold;
}

+ (BOOL)meetsMinimumRequiredTimelineViews {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
    NSUInteger viewsIn31Days = [appUsage usageWithin:HEMAppUsageIntervalLast31Days];
    return viewsIn31Days >= HEMMinimumTimelineViews;
}

+ (BOOL)meetsMinimumRequiredAppLaunches {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppLaunched];
    NSUInteger appLaunches = [appUsage usageWithin:HEMAppUsageIntervalLast7Days];
    return appLaunches >= HEMMinimumAppLaunches;
}

+ (BOOL)isWithinSystemAlertThreshold {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageSystemAlertShown];
    NSDate* lastUpdated = [appUsage updated];
    return !lastUpdated || [lastUpdated daysElapsed] > HEMSystemAlertShownThreshold;
}

+ (BOOL)hasStatedToStopAsking {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return [[localPrefs persistentPreferenceForKey:HEMNoMoreAsking] boolValue];
}

+ (BOOL)hasNotYetReviewedThisVersion {
    HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:[self appVersion]];
    return [appUsage updated] == nil;
}

+ (NSString*)appVersion {
    NSBundle* bundle = [NSBundle mainBundle];
    return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark - Questions

+ (HEMAppReviewQuestion*)appReviewQuestion {
    NSString* firstQuestionText = NSLocalizedString(@"app-review.question.1", nil);
    NSArray* firstQuestionAnswers = [self answersForQuestion:firstQuestionText];
    
    HEMAppReviewQuestion* conditionalQuestion = nil;
    NSMutableDictionary* conditionalQuestions = [NSMutableDictionary dictionary];
    for (HEMAppReviewAnswer* answer in firstQuestionAnswers) {
        conditionalQuestion = [self nextQuestionForAnswer:answer];
        if (conditionalQuestion) {
            conditionalQuestions[[answer answerId]] = conditionalQuestion;
        }
    }
    
    return [[HEMAppReviewQuestion alloc] initQuestion:firstQuestionText
                                              choices:firstQuestionAnswers
                                 conditionalQuestions:conditionalQuestions];
}

+ (HEMAppReviewQuestion*)nextQuestionForAnswer:(HEMAppReviewAnswer*)answer {
    if ([answer action] != HEMAppReviewAnswerActionEnjoySense
        && [answer action] != HEMAppReviewAnswerActionDoNotEnjoySense) {
        return nil;
    }
    
    NSString* nextQuestion = nil;
    
    if ([answer action] == HEMAppReviewAnswerActionEnjoySense) {
        nextQuestion = NSLocalizedString(@"app-review.question.2", nil);
    } else {
        nextQuestion = NSLocalizedString(@"app-review.question.3", nil);
    }
    
    NSArray* nextAnswers = [self answersForQuestion:nextQuestion];
    HEMAppReviewQuestion* question = [[HEMAppReviewQuestion alloc] initQuestion:nextQuestion
                                                                        choices:nextAnswers
                                                           conditionalQuestions:nil];
    
    return question;
}

#pragma mark - Answers

+ (NSArray*)answersForQuestion:(NSString*)question {
    NSArray* answers = nil;
    NSNumber* questionId = [HEMAppReviewQuestion questionIdForText:question];
    if ([question isEqualToString:NSLocalizedString(@"app-review.question.1", nil)]) {
        answers = [self answersForFirstQuestionWithId:questionId];
    } else if ([question isEqualToString:NSLocalizedString(@"app-review.question.2", nil)]) {
        answers = [self answersForSecondQuestionWithId:questionId];
    } else  if ([question isEqualToString:NSLocalizedString(@"app-review.question.3", nil)]) {
        answers = [self answersForThirdQuestionWithId:questionId];
    }
    return answers;
}

+ (NSArray*)answersForFirstQuestionWithId:(NSNumber*)questionId {
    NSString* answer1 = NSLocalizedString(@"app-review.question.answer.love-it", nil);
    NSString* answer2 = NSLocalizedString(@"app-review.question.answer.not-really", nil);
    NSString* answer3 = NSLocalizedString(@"app-review.question.answer.help", nil);
    
    HEMAppReviewAnswer* loveItAnswer = [[HEMAppReviewAnswer alloc] initWithAnswer:answer1
                                                                       questionId:questionId
                                                                           action:HEMAppReviewAnswerActionEnjoySense];
    HEMAppReviewAnswer* notReallyAnswer = [[HEMAppReviewAnswer alloc] initWithAnswer:answer2
                                                                          questionId:questionId
                                                                              action:HEMAppReviewAnswerActionDoNotEnjoySense];
    HEMAppReviewAnswer* needHelp = [[HEMAppReviewAnswer alloc] initWithAnswer:answer3
                                                                   questionId:questionId
                                                                       action:HEMAppReviewAnswerActionOpenSupport];
    return @[loveItAnswer, notReallyAnswer, needHelp];
}

+ (NSArray*)answersForSecondQuestionWithId:(NSNumber*)questionId {
    NSString* answer1 = NSLocalizedString(@"app-review.question.answer.sure", nil);
    NSString* answer2 = NSLocalizedString(@"app-review.question.answer.not-now", nil);
    NSString* answer3 = NSLocalizedString(@"app-review.question.answer.dont-ask-again", nil);
    
    HEMAppReviewAnswer* sure = [[HEMAppReviewAnswer alloc] initWithAnswer:answer1
                                                               questionId:questionId
                                                                   action:HEMAppReviewAnswerActionRateTheApp];
    HEMAppReviewAnswer* notNow = [[HEMAppReviewAnswer alloc] initWithAnswer:answer2
                                                                 questionId:questionId
                                                                     action:HEMAppReviewAnswerActionDone];
    HEMAppReviewAnswer* doNotAsk = [[HEMAppReviewAnswer alloc] initWithAnswer:answer3
                                                                   questionId:questionId
                                                                       action:HEMAppReviewAnswerActionStopAsking];
    return @[sure, notNow, doNotAsk];
}

+ (NSArray*)answersForThirdQuestionWithId:(NSNumber*)questionId {
    NSString* answer1 = NSLocalizedString(@"app-review.question.answer.sure", nil);
    NSString* answer2 = NSLocalizedString(@"app-review.question.answer.no-thanks", nil);
    
    HEMAppReviewAnswer* sure = [[HEMAppReviewAnswer alloc] initWithAnswer:answer1
                                                               questionId:questionId
                                                                   action:HEMAppReviewAnswerActionSendFeedback];
    HEMAppReviewAnswer* noThanks = [[HEMAppReviewAnswer alloc] initWithAnswer:answer2
                                                                   questionId:questionId
                                                                       action:HEMAppReviewAnswerActionDone];
    return @[sure, noThanks];
}

#pragma mark -

+ (void)markAppReviewPromptCompleted {
    [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageAppReviewPromptCompleted];
}

+ (void)stopAskingToRateTheApp {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setPersistentPreference:@(YES) forKey:HEMNoMoreAsking];
}

+ (void)rateApp {
    NSString* url = [HEMConfig stringForConfig:HEMConfAppReviewURL];
    if (url) {
        [HEMAppUsage incrementUsageForIdentifier:[self appVersion]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
