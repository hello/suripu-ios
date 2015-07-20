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
 *  Present a dialog to ask the user to rate the app
 *
 *  @param controller presenting controller for dialog
 *  @param completion YES if the user selects to rate the app
 */
+ (void)askToRateAppFrom:(UIViewController *)controller;

/**
 *  @return YES if the user has been asked to rate the app
 */
+ (BOOL)didAskToRateApp;

/**
 *  Send the user to the App Store review page
 */
+ (void)rateApp;
@end
