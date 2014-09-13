//
//  SENQuestion.m
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import "SENQuestion.h"

@interface SENQuestion()

@property (nonatomic, copy, readwrite)   NSNumber* questionId;
@property (nonatomic, copy, readwrite)   NSString* question;
@property (nonatomic, assign, readwrite) SENQuestionType type;
@property (nonatomic, copy, readwrite)   NSArray*  choices;

@end

@implementation SENQuestion

- (instancetype)initWithId:(NSNumber*)questionId
                  question:(NSString*)question
                      type:(SENQuestionType)type
                   choices:(NSArray*)choices {
    self = [super init];
    if (self) {
        [self setQuestionId:questionId];
        [self setQuestion:question];
        [self setType:type];
        [self setChoices:choices];
    }
    return self;
}

@end