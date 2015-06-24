//
//  SENServiceQuestions.m
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//
#import "SENAPIQuestions.h"
#import "SENAuthorizationService.h"
#import "SENServiceQuestions.h"
#import "SENService+Protected.h"
#import "SENAnswer.h"
#import "SENQuestion.h"

static NSString* const kSENServiceQuestionsKeyDate = @"kSENServiceQuestionsKeyDate";
static NSString* const SENServiceQuestionsErrorDomain = @"is.hello.service.questions";

@interface SENServiceQuestions()

@property (nonatomic, strong) NSDate* dateQuestionsPulled;
@property (nonatomic, copy)   NSArray* todaysQuestions;
@property (nonatomic, assign, getter=isUpdating) BOOL updating;

@end

@implementation SENServiceQuestions

+ (id)sharedService {
    static SENServiceQuestions* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

#pragma mark - Helpers

- (void)updateQuestions:(SENServiceQuestionBlock)completion {
    if (![SENAuthorizationService isAuthorized]) {
        if (completion) completion (nil, nil);
        return;
    }
    
    // if there are questions for today still left, return those
    if ([[self todaysQuestions] count] > 0 && [self isToday:[self dateQuestionsPulled]]) {
        if (completion) completion ([self todaysQuestions], nil);
        return;
    }
    
    if ([self isUpdating]) {
        if (completion) completion (nil, [NSError errorWithDomain:SENServiceQuestionsErrorDomain
                                                             code:SENServiceQuestionsErrorCodeUpdateInProgress
                                                         userInfo:nil]);
        return;
    }
    
    NSDate* today = [self todayWithoutTime];
    [self setUpdating:YES];
    __weak typeof(self) weakSelf = self;
    [SENAPIQuestions getQuestionsFor:today completion:^(NSArray* questions, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setTodaysQuestions:questions];
            [strongSelf setDateQuestionsPulled:today];
            [strongSelf setUpdating:NO];
            if (completion) completion (questions, error);
        }
    }];
}

- (NSDate*)todayWithoutTime {
    // since this method can be called multiple times during the lifecycle and on
    // restore, we should cache the instance so it does not take long to simply
    // go in to foreground since [NSCalendar calendarWithIdentifier:] is a little slow
    static NSCalendar* calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    unsigned flags = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents* now = [calendar components:flags fromDate:[NSDate date]];
    [now setCalendar:calendar];
    return [now date];
}

- (BOOL)isToday:(NSDate*)date {
    return date != nil ? [[self todayWithoutTime] compare:date] == NSOrderedSame : NO;
}

- (void)removeQuestion:(SENQuestion*)question {
    if (question == nil) return;
    
    NSMutableArray* questions = [[self todaysQuestions] mutableCopy];
    [questions removeObject:question];
    [self setTodaysQuestions:questions];
}

#pragma mark - Public

- (void)submitAnswer:(SENAnswer*)answer
         forQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion {
    [self submitAnswers:@[answer] forQuestion:question completion:completion];
}

- (void)submitAnswers:(NSArray*)answers
          forQuestion:(SENQuestion*)question
           completion:(void(^)(NSError* error))completion {
    
    // Let the API to fail with callback if answer parameter is insuffcient
    __block SENQuestion* questionToUpdate = question;
    __weak typeof (self) weakSelf = self;
    [SENAPIQuestions sendAnswers:answers forQuestion:question completion:^(id data, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && !error) {
            [strongSelf removeQuestion:questionToUpdate];
        }
        if (completion) completion (error);
    }];
    
}

- (void)skipQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion {
    // Let the API to fail with callback if question parameter is insuffcient
    __block SENQuestion* questionToUpdate = question;
    __weak typeof (self) weakSelf = self;
    [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && [error code] != SENAPIQuestionErrorInvalidParameter) {
            [strongSelf removeQuestion:questionToUpdate];
        }
        if (completion) completion (error);
    }];
}

@end