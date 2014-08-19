//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Delisa Mason. All rights reserved.
//

#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingController+Protected.h"

@interface HEMWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)signup:(id)sender {
    NSLog(@"sign up");
    UIViewController* signupVC = [HEMOnboardingStoryboard instantiateSignUpViewController];
    [self pushViewController:signupVC progress:1/9.0f];
}

- (IBAction)signin:(id)sender {
    NSLog(@"sign in");
}

@end
