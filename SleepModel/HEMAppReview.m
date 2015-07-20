//
//  HEMAppReview.m
//  Sense
//
//  Created by Delisa Mason on 7/20/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import "HEMAppReview.h"
#import "HEMAlertViewController.h"

@implementation HEMAppReview

NSString *const HEMReviewPrompted = @"HEMReviewPrompted";

+ (void)askToRateAppFrom:(UIViewController *)controller {
    [self setDidAskToRateApp];
    [HEMAlertViewController
        showBooleanChoiceDialogWithTitle:NSLocalizedString(@"review.like-app.title", nil)
                                 message:NSLocalizedString(@"review.like-app.message", nil)
                              controller:controller
                                  action:^{
                                    [controller dismissViewControllerAnimated:YES
                                                                   completion:^{
                                                                     [self presentAppRatingDialogFrom:controller];
                                                                   }];
                                  }];
}

+ (BOOL)didAskToRateApp {
    return [[[SENLocalPreferences sharedPreferences] userPreferenceForKey:HEMReviewPrompted] boolValue];
}

+ (void)rateApp {
    NSString *const HEMReviewURI = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/"
        @"viewContentsUserReviews?id=942698761&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:HEMReviewURI]];
}

+ (void)presentAppRatingDialogFrom:(UIViewController *)controller {
    [HEMAlertViewController showBooleanChoiceDialogWithTitle:NSLocalizedString(@"review.rate-app.title", nil)
                                                     message:NSLocalizedString(@"review.rate-app.message", nil)
                                                  controller:controller
                                                      action:^{
                                                        [controller dismissViewControllerAnimated:YES completion:NULL];
                                                        [self rateApp];
                                                      }];
}

+ (void)setDidAskToRateApp {
    SENLocalPreferences *preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:@(YES) forKey:HEMReviewPrompted];
}
@end
