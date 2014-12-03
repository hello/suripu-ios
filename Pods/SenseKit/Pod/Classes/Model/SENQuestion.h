//
//  SENQuestion.h
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENQuestionType) {
    SENQuestionTypeChoice
};

@interface SENQuestion : NSObject

@property (nonatomic, copy, readonly)   NSNumber* questionId;
@property (nonatomic, copy, readonly)   NSNumber* questionAccountId;
@property (nonatomic, copy, readonly)   NSString* text;
@property (nonatomic, assign, readonly) SENQuestionType type;
@property (nonatomic, copy, readonly)   NSArray*  choices;

- (instancetype)initWithId:(NSNumber*)questionId
         questionAccountId:(NSNumber*)questionAccountId
                  question:(NSString*)question
                      type:(SENQuestionType)type
                   choices:(NSArray*)choices;

@end