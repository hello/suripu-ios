//
//  HEMSetupDoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSetupDoneViewController.h"
#import "HEMActionButton.h"

@interface HEMSetupDoneViewController()

@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSetupDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
}

- (IBAction)finish:(id)sender {
    if (![self continueWithFlowBySkipping:NO]) {
        [self completeOnboardingWithoutMessage];
    }
}

@end
