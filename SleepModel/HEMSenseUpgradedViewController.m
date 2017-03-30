//
//  HEMSenseUpgradedViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMSenseUpgradedViewController.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSenseUpgradedViewController()

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;

@end

@implementation HEMSenseUpgradedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static NSString* imageKey = @"sense.illustration";
    UIImage* illustration = [SenseStyle imageWithAClass:[self class]
                                           propertyName:imageKey];
    [[self illustrationView] setImage:illustration];
}

- (IBAction)proceed:(id)sender {
    if (![self continueWithFlowBySkipping:NO]) {
        NSString* segueId = [HEMOnboardingStoryboard pairPillSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

@end
