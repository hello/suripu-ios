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
@property (nonatomic, copy, readwrite)   NSNumber* questionAccountId;
@property (nonatomic, copy, readwrite)   NSString* text;
@property (nonatomic, assign, readwrite) SENQuestionType type;
@property (nonatomic, copy, readwrite)   NSArray*  choices;

@end

@implementation SENQuestion

- (instancetype)initWithId:(NSNumber*)questionId
         questionAccountId:(NSNumber*)questionAccountId
                  question:(NSString*)question
                      type:(SENQuestionType)type
                   choices:(NSArray*)choices {
    
    self = [super init];
    if (self) {
        [self setQuestionId:questionId];
        [self setQuestionAccountId:questionAccountId];
        [self setText:question];
        [self setType:type];
        [self setChoices:choices];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == nil) return NO;
    if (![object isKindOfClass:[self class]]) return NO;
    
    SENQuestion* otherQuestion = (SENQuestion*)object;
    return [[otherQuestion questionId] isEqualToNumber:[self questionId]];
}

- (NSUInteger)hash {
    return [[self questionId] hash];
}

@end