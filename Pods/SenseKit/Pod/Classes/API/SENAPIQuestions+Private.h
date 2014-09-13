//
//  SENAPIQuestions+Private.h
//  Pods
//
//  Created by Jimmy Lu on 9/12/14.
//
//

#import "SENAPIQuestions.h"

@class SENQuestion;

@interface SENAPIQuestions (Private)

+ (SENQuestion*)questionFromDict:(NSDictionary*)questionDict;
+ (NSArray*)answersFromReponseArray:(NSArray*)responesArray;
+ (NSArray*)questionsFromResponse:(id)response;

@end