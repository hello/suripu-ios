//
//  HEMOnboardingUtils.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAPIAccount.h>

#import <AFNetworking/AFURLResponseSerialization.h>

#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMUserDataCache.h"
#import "HEMAlertController.h"

static NSString* const kHEMOnboardingSettingCheckpoint = @"sense.checkpoint";
static CGFloat   const kHEMOnboardingDefaultFontSize = 18.0f;

@implementation HEMOnboardingUtils

+ (void)applyCommonDescriptionAttributesTo:(NSMutableAttributedString*)attrText {
    UIFont* font = [UIFont fontWithName:@"Calibre-Thin" size:kHEMOnboardingDefaultFontSize];
    UIColor* color = [HelloStyleKit onboardingGrayColor];
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineHeightMultiple:1.3f];
    
    // avoid overriding any substrings that may already have attributes set
    [attrText enumerateAttributesInRange:NSMakeRange(0, [attrText length])
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                  if ([attrs valueForKey:NSFontAttributeName] == nil) {
                                      [attrText addAttribute:NSFontAttributeName
                                                       value:font
                                                       range:range];
                                  }
                                  
                                  if ([attrs valueForKey:NSForegroundColorAttributeName] == nil) {
                                      [attrText addAttribute:NSForegroundColorAttributeName
                                                       value:color
                                                       range:range];
                                  }
                                  
                                  if ([attrs valueForKey:NSParagraphStyleAttributeName] == nil) {
                                      [attrText addAttribute:NSParagraphStyleAttributeName
                                                       value:paragraphStyle
                                                       range:range];
                                  }
                              }];
}

+ (NSAttributedString*)boldAttributedText:(NSString*)text {
    return [self boldAttributedText:text withColor:nil];
}

+ (NSAttributedString*)boldAttributedText:(NSString *)text withColor:(UIColor*)color {
    UIFont* font = [UIFont fontWithName:@"Calibre-Medium" size:kHEMOnboardingDefaultFontSize];
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [attributes setValue:font forKey:NSFontAttributeName];
    
    if (color != nil) {
        [attributes setValue:color forKey:NSForegroundColorAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Checkpoints

+ (void)saveOnboardingCheckpoint:(HEMOnboardingCheckpoint)checkpoint {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:checkpoint forKey:kHEMOnboardingSettingCheckpoint];
    [defaults synchronize]; // save now in case user kills app or something else
}

+ (HEMOnboardingCheckpoint)onboardingCheckpoint {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kHEMOnboardingSettingCheckpoint];
}

+ (void)resetOnboardingCheckpoint {
    [self saveOnboardingCheckpoint:HEMOnboardingCheckpointStart];
}

#pragma mark - Errors

+ (void)showAlertForHTTPError:(NSError*)error
                    withTitle:(NSString*)errorTitle
                         from:(UIViewController*)controller {
    
    NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    [HEMAlertController presentInfoAlertWithTitle:errorTitle
                                          message:[self httpErrorMessageForStatusCode:[response statusCode]]
                             presentingController:controller];
}

+ (NSString*)httpErrorMessageForStatusCode:(NSInteger)statusCode {
    NSString* message = nil;
    // note that we will not attempt to create a message for every error code
    // that exists, but rather only for those that are commonly encountered.
    // We should never return the localizedDescription here as that provides
    // the user a unfriendly message that only iOS developers can actually understand
    switch (statusCode) {
        case 401:
            message = NSLocalizedString(@"authorization.sign-in.failed.message", nil);
            break;
        case 409:
            message = NSLocalizedString(@"sign-up.error.conflict", nil);
            break;
        case NSURLErrorNotConnectedToInternet:
            message = NSLocalizedString(@"network.error.not-connected", nil);
            break;
        case NSURLErrorNetworkConnectionLost:
            message = NSLocalizedString(@"network.error.connection-lost", nil);
            break;
        case NSURLErrorCannotConnectToHost:
            message = NSLocalizedString(@"network.error.cannot-connect-to-host", nil);
            break;
        case NSURLErrorTimedOut:
            message = NSLocalizedString(@"network.error.timed-out", nil);
            break;
        default:
            message = NSLocalizedString(@"sign-up.error.generic", nil);
            break;
    }
    return message;
}

@end
