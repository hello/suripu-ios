//
//  HEMAppReview.m
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENPairedDevices.h>

#import "HEMAppReview.h"
#import "HEMAppUsage.h"
#import "HEMAlertViewController.h"
#import "NSDate+HEMRelative.h"
#import "HEMConfig.h"
#import "HEMAppReviewQuestion.h"
#import "HEMAppReviewAnswer.h"
#import "HEMDeviceService.h"

@implementation HEMAppReview

static NSUInteger const HEMAppPromptReviewThreshold = 60;
static NSUInteger const HEMMinimumAppLaunches = 4;
static NSUInteger const HEMSystemAlertShownThreshold = 15;
static NSUInteger const HEMMinimumTimelineViews = 5;
static NSString* const HEMAmazonReview = @"app.review.amazon";
static NSString* const HEMNoMoreAsking = @"stop.asking.to.rate.app";
static NSString* const HEMLocalizedKeyQuestion1 = @"app-review.question.1";
static NSString* const HEMLocalizedKeyQuestion2 = @"app-review.question.2";
static NSString* const HEMLocalizedKeyQuestion2Amazon = @"app-review.question.2.amazon";
static NSString* const HEMLocalizedKeyQuestion3 = @"app-review.question.3";
static NSString* const HEMLocalizedKeyAnswerHelp = @"app-review.question.answer.help";
static NSString* const HEMLocalizedKeyAnswerLoveIt = @"app-review.question.answer.love-it";
static NSString* const HEMLocalizedKeyAnswerNotReally = @"app-review.question.answer.not-really";
static NSString* const HEMLocalizedKeyAnswerSure = @"app-review.question.answer.sure";
static NSString* const HEMLocalizedKeyAnswerRate = @"app-review.question.answer.rate-it";
static NSString* const HEMLocalizedKeyAnswerNotNow = @"app-review.question.answer.not-now";
static NSString* const HEMLocalizedKeyAnswerDoNotAsk = @"app-review.question.answer.dont-ask-again";
static NSString* const HEMLocalizedKeyAnswerNoThanks = @"app-review.question.answer.no-thanks";

static NSString* const HEMAmazonReviewResourceName = @"AmazonReviews";
static NSString* const HEMAmazonReviewForVoiceResourceName = @"AmazonReviewsForVoice";

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
                    HEMAppReviewType type = HEMAppReviewTypeAppStore;
                    if ([self isEligibleToReviewOnAmazon]
                        && ![self hasBeenAskedToReviewOnAmazon]) {
                        type = HEMAppReviewTypeAmazon;
                    }
                    question = [self appReviewQuestion:type];
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
        SENPairedDevices* devices = [deviceService devices];
        completion (error == nil && [devices hasPairedSense] && [devices hasPairedPill]);
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

+ (BOOL)hasBeenAskedToReviewOnAmazon {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return [[localPrefs persistentPreferenceForKey:HEMAmazonReview] boolValue];
}

+ (BOOL)isEligibleToReviewOnAmazon {
    return [self amazonReviewLink] != nil;
}

+ (NSString*)amazonReviewLink {
    NSString* countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return [[self amazonReviewLinks] valueForKey:[countryCode uppercaseString]];
}

+ (NSDictionary*)amazonReviewLinks {
    static NSDictionary* linksByCode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HEMDeviceService* deviceService = [HEMDeviceService new];
        SENSenseHardware hardwareVersion = [deviceService savedHardwareVersion];
        NSString* resourceName = nil;
        switch (hardwareVersion) {
            case SENSenseHardwareVoice:
                resourceName = HEMAmazonReviewForVoiceResourceName;
                break;
            case SENSenseHardwareOne:
            default:
                resourceName = HEMAmazonReviewResourceName;
                break;
        }
        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"plist"];
        linksByCode = [NSDictionary dictionaryWithContentsOfFile:path];
    });
    return linksByCode;
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

+ (HEMAppReviewQuestion*)appReviewQuestion:(HEMAppReviewType)reviewType {
    NSString* firstQuestionText = NSLocalizedString(HEMLocalizedKeyQuestion1, nil);
    NSArray* firstQuestionAnswers = [self answersForQuestion:firstQuestionText];
    
    HEMAppReviewQuestion* conditionalQuestion = nil;
    NSMutableDictionary* conditionalQuestions = [NSMutableDictionary dictionary];
    for (HEMAppReviewAnswer* answer in firstQuestionAnswers) {
        conditionalQuestion = [self nextQuestionForAnswer:answer reviewType:reviewType];
        if (conditionalQuestion) {
            conditionalQuestions[[answer answerId]] = conditionalQuestion;
        }
    }
    
    return [[HEMAppReviewQuestion alloc] initQuestion:firstQuestionText
                                              choices:firstQuestionAnswers
                                 conditionalQuestions:conditionalQuestions];
}

+ (HEMAppReviewQuestion*)nextQuestionForAnswer:(HEMAppReviewAnswer*)answer
                                    reviewType:(HEMAppReviewType)reviewType {
    
    if ([answer action] != HEMAppReviewAnswerActionEnjoySense
        && [answer action] != HEMAppReviewAnswerActionDoNotEnjoySense) {
        return nil;
    }
    
    NSString* nextQuestion = nil;

    if ([answer action] == HEMAppReviewAnswerActionEnjoySense) {
        switch (reviewType) {
            case HEMAppReviewTypeAmazon:
                nextQuestion = NSLocalizedString(@"app-review.question.2.amazon", nil);
                break;
            case HEMAppReviewTypeAppStore:
            default:
                nextQuestion = NSLocalizedString(@"app-review.question.2", nil);
                break;
        }
    } else {
        nextQuestion = NSLocalizedString(@"app-review.question.3", nil);
    }
    
    NSArray* nextAnswers = [self answersForQuestion:nextQuestion];
    HEMAppReviewQuestion* question = [[HEMAppReviewQuestion alloc] initQuestion:nextQuestion
                                                                        choices:nextAnswers
                                                           conditionalQuestions:nil];
    [question setReviewType:reviewType];
    
    return question;
}

#pragma mark - Answers

+ (NSArray*)answersForQuestion:(NSString*)question {
    NSArray* answers = nil;
    NSNumber* questionId = [HEMAppReviewQuestion questionIdForText:question];
    if ([question isEqualToString:NSLocalizedString(HEMLocalizedKeyQuestion1, nil)]) {
        answers = [self answersForFirstQuestionWithId:questionId];
    } else if ([question isEqualToString:NSLocalizedString(HEMLocalizedKeyQuestion2, nil)]
               || [question isEqualToString:NSLocalizedString(HEMLocalizedKeyQuestion2Amazon, nil)]) {
        answers = [self answersForSecondQuestionWithId:questionId];
    } else  if ([question isEqualToString:NSLocalizedString(HEMLocalizedKeyQuestion3, nil)]) {
        answers = [self answersForThirdQuestionWithId:questionId];
    }
    return answers;
}

+ (NSArray*)answersForFirstQuestionWithId:(NSNumber*)questionId {
    NSString* answer1 = NSLocalizedString(HEMLocalizedKeyAnswerLoveIt, nil);
    NSString* answer2 = NSLocalizedString(HEMLocalizedKeyAnswerNotReally, nil);
    NSString* answer3 = NSLocalizedString(HEMLocalizedKeyAnswerHelp, nil);
    
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
    NSString* answer1 = NSLocalizedString(HEMLocalizedKeyAnswerRate, nil);
    NSString* answer2 = NSLocalizedString(HEMLocalizedKeyAnswerNotNow, nil);
    NSString* answer3 = NSLocalizedString(HEMLocalizedKeyAnswerDoNotAsk, nil);
    
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
    NSString* answer1 = NSLocalizedString(HEMLocalizedKeyAnswerSure, nil);
    NSString* answer2 = NSLocalizedString(HEMLocalizedKeyAnswerNoThanks, nil);
    
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

+ (void)stopAskingToReviewOnAmazon {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setPersistentPreference:@(YES) forKey:HEMAmazonReview];
}

+ (void)rateApp:(HEMAppReviewType)reviewType {
    NSString* url = nil;
    switch (reviewType) {
        case HEMAppReviewTypeAmazon:
            url = [self amazonReviewLink];
            [self stopAskingToReviewOnAmazon];
            break;
        case HEMAppReviewTypeAppStore:
        default:
            url = [HEMConfig stringForConfig:HEMConfAppReviewURL];
            break;
    }
    
    if (url) {
        [HEMAppUsage incrementUsageForIdentifier:[self appVersion]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
