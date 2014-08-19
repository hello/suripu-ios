//
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMOnboardingController.h"
#import "HEMProgressController.h"

@implementation HEMOnboardingController

- (void)pushViewController:(UIViewController*)controller progress:(float)progress {
    if ([[self parentViewController] isKindOfClass:[HEMProgressController class]]) {
        HEMProgressController* progressController = (HEMProgressController*)[self parentViewController];
        [progressController pushViewController:controller progress:progress animated:YES completion:nil];
    } else if (([[self parentViewController] isKindOfClass:[UINavigationController class]])) {
        UINavigationController* nav = (UINavigationController*)[self parentViewController];
        [nav pushViewController:controller animated:YES];
    }
}

@end
