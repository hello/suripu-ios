//
//  UIActivityViewController+HEMSharing.m
//  Sense
//
//  Created by Jimmy Lu on 6/23/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIActivityViewController+HEMSharing.h"
#import "HEMShareContentProvider.h"
#import "HEMConfirmationView.h"

@implementation UIActivityViewController (HEMSharing)

+ (instancetype)share:(id)item ofType:(NSString*)type fromView:(UIView*)view {
    HEMShareContentProvider* content = [[HEMShareContentProvider alloc] initWithItemToShare:item forType:type];
    
    UIActivityViewController* controller =
        [[UIActivityViewController alloc] initWithActivityItems:@[content] applicationActivities:nil];
    
    __weak typeof(view) weakContainer = view;
    [controller setCompletionWithItemsHandler:^(NSString * activityType, BOOL completed, NSArray * returnedItems, NSError * activityError){
        __strong typeof(weakContainer) strongContainer = weakContainer;
        if (!completed) {
            return;
        }
        
        if (activityError) {
            [SENAnalytics trackError:activityError];
        }
        
        NSString* text = nil;
        HEMConfirmationLayout layout = HEMConfirmationLayoutVertical;
        if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
            text = NSLocalizedString(@"status.copied", nil);
            layout = HEMConfirmationLayoutHorizontal;
        } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
            text = NSLocalizedString(@"status.shared", nil);
        }
        
        if (text) {
            HEMConfirmationView* confirmView =
                [[HEMConfirmationView alloc] initWithText:text layout:layout];
            [confirmView showInView:strongContainer];
        }
        
        NSDictionary* props = @{kHEMAnalyticsEventPropType : type ?: @"",
                                HEMAnalyticsPropService : activityType ?: @""};
        [SENAnalytics track:HEMAnalyticsEventShareComplete properties:props];
    }];
    
    return controller;
}

@end
