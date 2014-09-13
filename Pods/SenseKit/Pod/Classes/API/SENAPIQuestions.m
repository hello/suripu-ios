//
//  SENAPIQuestions.m
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//
#import "AFHTTPSessionManager.h"
#import "SENAPIQuestions.h"
#import "SENQuestion.h"
#import "SENAnswer.h"

static NSDateFormatter* dateFormatter;

static NSString* const kSENAPIQuestionErrorDomain = @"is.hello.api.question";

static NSString* const kSENAPIQuestionsPath = @"questions";
static NSString* const kSENAPIQuestionPropId = @"id";
static NSString* const kSENAPIQuestionPropQuestionId = @"question_id";
static NSString* const kSENAPIQuestionPropText = @"text";
static NSString* const kSENAPIQuestionPropType = @"type";
static NSString* const kSENAPIQuestionPropChoices = @"choices";
static NSString* const kSENAPIQuestionTypeChoice = @"CHOICE";

@implementation SENAPIQuestions

#pragma mark - GET QUESTIONS

+ (id)object:(id)object mustBe:(Class)class {
    return [object isKindOfClass:class]?object:nil;
}

+ (SENQuestionType)typeFromString:(NSString*)typeString {
    SENQuestionType type = SENQuestionTypeChoice;
    if ([[typeString uppercaseString] isEqualToString:kSENAPIQuestionTypeChoice]) {
        type = SENQuestionTypeChoice;
    }
    return type;
}

+ (NSArray*)answersFromReponseArray:(NSArray*)responesArray {
    NSMutableArray* answers = [NSMutableArray arrayWithCapacity:[responesArray count]];
    for (id answerObject in responesArray) {
        NSDictionary* answerDict = [self object:answerObject mustBe:[NSDictionary class]];
        NSNumber* ansId = [self object:[answerDict objectForKey:kSENAPIQuestionPropId] mustBe:[NSNumber class]];
        NSNumber* queId = [self object:[answerDict objectForKey:kSENAPIQuestionPropQuestionId] mustBe:[NSNumber class]];
        NSString* text = [self object:[answerDict objectForKey:kSENAPIQuestionPropText] mustBe:[NSString class]];
        if (ansId != nil && queId != nil && text != nil) {
            [answers addObject:[[SENAnswer alloc] initWithId:ansId answer:text questionId:queId]];
        }
    }
    return answers;
}


+ (SENQuestion*)questionFromDict:(NSDictionary*)questionDict {
    NSNumber* qId = [self object:[questionDict objectForKey:kSENAPIQuestionPropId] mustBe:[NSNumber class]];
    NSString* text = [self object:[questionDict objectForKey:kSENAPIQuestionPropText] mustBe:[NSString class]];
    NSString* type = [self object:[questionDict objectForKey:kSENAPIQuestionPropType] mustBe:[NSString class]];
    NSArray* choiceObjs = [self object:[questionDict objectForKey:kSENAPIQuestionPropChoices] mustBe:[NSArray class]];
    
    if (qId == nil || [text length] == 0) {
        return nil;
    }
    
    return [[SENQuestion alloc] initWithId:qId
                                  question:text
                                      type:[self typeFromString:type]
                                   choices:[self answersFromReponseArray:choiceObjs]];
}

+ (NSArray*)questionsFromResponse:(id)response {
    NSMutableArray* questions = [NSMutableArray array];
    if ([response isKindOfClass:[NSArray class]]) {
        for (id responseObj in response) {
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                [questions addObject:[self questionFromDict:responseObj]];
            }
        }
    }
    return questions;
}

+ (void)getQuestionsFor:(NSDate*)date completion:(SENAPIDataBlock)completion {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    
    NSString* dateParam
    = date != nil
    ? [NSString stringWithFormat:@"?date=%@", [dateFormatter stringFromDate:date]]
    : @"";
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", kSENAPIQuestionsPath, dateParam];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        if (completion) {
            if (error == nil) {
                completion ([self questionsFromResponse:data], error);
            } else {
                completion (nil, error);
            }
        }
    }];
}

#pragma mark - SENDING RESPONSES

+ (NSDictionary*)dictionaryValueForAnswer:(SENAnswer*)answer {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:[answer answerId] forKey:kSENAPIQuestionPropId];
    [dict setValue:[answer answer] forKey:kSENAPIQuestionPropText];
    return dict;
}

+ (void)sendAnswer:(SENAnswer*)answer completion:(SENAPIDataBlock)completion {
    if (answer == nil || [answer answerId] == nil) {
        if (completion) completion (nil, [NSError errorWithDomain:kSENAPIQuestionErrorDomain
                                                             code:SENAPIQuestionErrorInvalidParameter
                                                         userInfo:nil]);
        return;
    }
    
    NSString* path = [NSString stringWithFormat:@"%@", kSENAPIQuestionsPath];
    NSDictionary* answerDict = [self dictionaryValueForAnswer:answer];
    [SENAPIClient POST:path parameters:answerDict completion:completion];
}

@end