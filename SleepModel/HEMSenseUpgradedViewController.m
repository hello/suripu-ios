//
//  HEMSenseUpgradedViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSenseUpgradedViewController.h"
#import "HEMOnboardingStoryboard.h"

@implementation HEMSenseUpgradedViewController

- (IBAction)proceed:(id)sender {
    if (![self continueWithFlow]) {
        NSString* segueId = [HEMOnboardingStoryboard pairPillSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

@end
