//
//  SENAPIAppReviewFeedback.h
//  Pods
//
//  Created by Jimmy Lu on 8/26/15.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSUInteger, SENAppReviewFeedback) {
    SENAppReviewFeedbackLikeIt = 0,
    SENAppReviewFeedbackDoNotLikeIt = 1,
    SENAppReviewFeedbackNeedHelp = 2
};

@interface SENAPIAppFeedback : NSObject

+ (void)sendAppFeedback:(SENAppReviewFeedback)feedback
            reviewedApp:(BOOL)reviewed
             completion:(SENAPIErrorBlock)completion;

@end
