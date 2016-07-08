//
//  SENAnswer.m
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import "SENAnswer.h"

@interface SENAnswer()

@property (nonatomic, strong, readwrite) NSNumber* answerId;
@property (nonatomic, copy, readwrite) NSString* answer;
@property (nonatomic, strong, readwrite) NSNumber* questionId;

@end

@implementation SENAnswer

- (instancetype)initWithId:(NSNumber*)answerId
                    answer:(NSString*)answer
                questionId:(NSNumber*)questionId {
    
    self = [super init];
    if (self) {
        [self setAnswerId:answerId];
        [self setAnswer:answer];
        [self setQuestionId:questionId];
    }
    return self;
    
}

@end