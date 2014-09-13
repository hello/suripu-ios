//
//  SENAPIQuestions.h
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENAnswer;

typedef NS_ENUM(NSInteger, SENAPIQuestionError) {
    SENAPIQuestionErrorInvalidParameter = -1
};

@interface SENAPIQuestions : NSObject

/**
 * Get questions that user of current account should answer.  This requires
 * that the user is signed in / authorized.
 *
 * Upon successfully retrieving the questions, the completion block will be
 * invoked with an NSArray of SENQuestion objects.
 *
 * @param date:       the date with which the questions are tied to,
 *                    or nil if not relevant
 * @param completion: block to invoke when response is ready
 */
+ (void)getQuestionsFor:(NSDate*)date completion:(SENAPIDataBlock)completion;

/**
 * Reply to a question with an answer.  The answer object should contain the
 * answer id, which will map back to the question this answer is meant for.
 *
 * @param answer:     the answer to a particular question
 * @param completion: the block to invoke when process succeeds
 */
+ (void)sendAnswer:(SENAnswer*)answer completion:(SENAPIDataBlock)completion;

@end