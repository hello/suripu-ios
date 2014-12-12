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

@interface SENServiceQuestions()

@property (nonatomic, strong) NSDate* lastDateAsked;
@property (nonatomic, strong) NSDate* today;
@property (nonatomic, strong) NSDate* dateQuestionsPulled;
@property (nonatomic, copy)   NSArray* todaysQuestions;
@property (nonatomic, strong) NSMutableDictionary* callbacksByObserver;
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

- (id)init {
    self = [super init];
    if (self) {
        [self restore];
        [self updateQuestions];
    }
    return self;
}

#pragma mark - SENService Override

- (void)serviceBecameActive {
    [self restore];
    [self updateQuestions];
}

- (void)serviceWillBecomeInactive {
    [self save];
}

#pragma mark - Helpers

- (void)updateQuestions {
    if (![self haveAskedQuestionsForToday] && [SENAuthorizationService isAuthorized]) {
        if ([self todaysQuestions] != nil && [self isToday:[self dateQuestionsPulled]]) {
            // just tell the observer there are questions to be asked to the user
            [self notifyObserversOfQuestions];
            return;
        }
        
        if ([self isUpdating]) {
            return;
        }
        
        [self setUpdating:YES];
        __weak typeof(self) weakSelf = self;
        [SENAPIQuestions getQuestionsFor:[self today] completion:^(NSArray* questions, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf setTodaysQuestions:questions];
                [strongSelf setDateQuestionsPulled:[strongSelf today]];
                [strongSelf notifyObserversOfQuestions];
                [strongSelf setUpdating:NO];
            }
        }];
    }
}

- (void)restore {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [self setLastDateAsked:[defaults objectForKey:kSENServiceQuestionsKeyDate]];
    [self setToday:[self todayWithoutTime]];
}

- (void)save {
    if ([self lastDateAsked] != nil) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[self lastDateAsked] forKey:kSENServiceQuestionsKeyDate];
        [defaults synchronize];
    }
}

- (void)notifyObserversOfQuestions {
    for (NSString* key in [self callbacksByObserver]) {
        SENServiceQuestionBlock callback = [[self callbacksByObserver] objectForKey:key];
        callback([self todaysQuestions]);
    }
}

- (NSDate*)todayWithoutTime {
    // since this method can be called multiple times during the lifecycle and on
    // restore, we should cache the instance so it does not take long to simply
    // go in to foreground since [NSCalendar currentCalendar] is a little slow
    static NSCalendar* calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
    });
    unsigned flags = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents* now = [calendar components:flags fromDate:[NSDate date]];
    [now setCalendar:calendar];
    return [now date];
}

- (BOOL)isToday:(NSDate*)date {
    return date != nil ? [[self today] compare:date] == NSOrderedSame : NO;
}

- (BOOL)haveAskedQuestionsForToday {
    return [self lastDateAsked] != nil
    && [self isToday:[self lastDateAsked]];
}

#pragma mark - Public

- (void)setQuestionsAskedToday {
    [self setLastDateAsked:[self today]];
    [self setTodaysQuestions:nil];
    [self save];
}

- (id)listenForNewQuestions:(void(^)(NSArray* questions))callback {
    if (callback == nil || callback == NULL) return nil;
    
    if ([self callbacksByObserver] == nil) {
        [self setCallbacksByObserver:[NSMutableDictionary dictionary]];
    }
    
    NSString* uuid = [[NSUUID UUID] UUIDString];
    [[self callbacksByObserver] setValue:[callback copy] forKey:uuid];
    return uuid;
}

- (void)stopListening:(id)listener {
    if (listener == nil || listener == NULL) return;
    [[self callbacksByObserver] removeObjectForKey:listener];
}

- (void)submitAnswer:(SENAnswer*)answer
         forQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion {
    [self submitAnswers:@[answer] forQuestion:question completion:completion];
}

- (void)submitAnswers:(NSArray*)answers
          forQuestion:(SENQuestion*)question
           completion:(void(^)(NSError* error))completion {
    
    // Let the API to fail with callback if answer parameter is insuffcient
    __weak typeof (self) weakSelf = self;
    [SENAPIQuestions sendAnswers:answers forQuestion:question completion:^(id data, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && !error) {
            // note that by answering one question, we aren't neccessarily saying
            // we have asked all the questions for the day, but for user experience
            // sake we will not annoy the user with more questions.  Same applies to
            // skipping a question.  This is why we will mark all questions as
            // asked today, even if only one in the set is asked / answered
            [strongSelf setQuestionsAskedToday];
        }
        if (completion) completion (error);
    }];
    
}

- (void)skipQuestion:(SENQuestion*)question
          completion:(void(^)(NSError* error))completion {
    // Let the API to fail with callback if question parameter is insuffcient
    __weak typeof (self) weakSelf = self;
    [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (strongSelf && [error code] != SENAPIQuestionErrorInvalidParameter) {
            // set questionas as asked for today unless error exists and it's
            // an invalid parameter.  If error returned from any other reason,
            // we will simply just not ask again for today.
            [strongSelf setQuestionsAskedToday];
        }
        if (completion) completion (error);
    }];
}

@end