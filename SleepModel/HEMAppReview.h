//
//  HEMAppReview.h
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMAppReview : NSObject

/**
 *  @discussion
 *  This is an asynchronous call as much of the work happens on a separate thread
 *  and makes asynchronous calls to check state of the system.
 * 
 *  @param completion: block to invoke when decision to ask is determined
 */
+ (void)shouldAskUserToRateTheApp:(void(^)(BOOL ask))completion;

/**
 *  Send the user to the App Store review page
 */
+ (void)rateApp;

@end
