//
//  SENAPIAppReviewFeedback.m
//  Pods
//
//  Created by Jimmy Lu on 8/26/15.
//
//

#import "SENAPIAppFeedback.h"

static NSString* const SENAPIAppFeedbackResource = @"v2/store/feedback";
static NSString* const SENAPIAppFeedbackPropLike = @"like";
static NSString* const SENAPIAppFeedbackPropReview = @"review";

@implementation SENAPIAppFeedback

+ (void)sendAppFeedback:(SENAppReviewFeedback)feedback
            reviewedApp:(BOOL)reviewed
             completion:(SENAPIErrorBlock)completion {
    NSString* feedbackValue = [self stringValueForFeedback:feedback];
    NSDictionary* parameters = @{SENAPIAppFeedbackPropLike : feedbackValue,
                                 SENAPIAppFeedbackPropReview : @(reviewed)};
    
    [SENAPIClient POST:SENAPIAppFeedbackResource
            parameters:parameters
            completion:^(id data, NSError *error) {
                if (completion) {
                    completion (error);
                }
            }];
}

+ (NSString*)stringValueForFeedback:(SENAppReviewFeedback)feedback {
    switch (feedback) {
        case SENAppReviewFeedbackDoNotLikeIt:
            return @"NO";
        case SENAppReviewFeedbackNeedHelp:
            return @"HELP";
        case SENAppReviewFeedbackLikeIt:
        default:
            return @"YES";
    }
}

@end
