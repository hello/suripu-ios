//
//  HEMAppReview.h
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMAppReviewQuestion.h"
#import "HEMAppReviewAnswer.h"
#import "HEMAppReviewQuestionsDataSource.h"

@interface HEMAppReview : NSObject

/**
 *  @discussion
 *  This is an asynchronous call since much of the work happens on a separate thread
 *  and makes asynchronous calls to check state of the system.
 * 
 *  @param completion: block to invoke when decision to ask is determined
 */
+ (void)shouldAskUserToRateTheApp:(void(^)(HEMAppReviewQuestion* question))completion;

/**
 *  Send the user to the App Store review page
 */
+ (void)rateApp;

/**
 *  @discussion
 *  Mark the review prompt as completed, until next time
 */
+ (void)markAppReviewPromptCompleted;

/**
 *  @discussion
 *  Stop asking, as long as the app is installed, to rate the app
 */
+ (void)stopAskingToRateTheApp;

@end
