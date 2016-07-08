//
//  SENAnswer.h
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import <Foundation/Foundation.h>

@interface SENAnswer : NSObject

@property (nonatomic, strong, readonly) NSNumber* answerId;
@property (nonatomic, copy, readonly) NSString* answer;
@property (nonatomic, strong, readonly) NSNumber* questionId;

- (instancetype)initWithId:(NSNumber*)answerId
                    answer:(NSString*)answer
                questionId:(NSNumber*)questionId;

@end