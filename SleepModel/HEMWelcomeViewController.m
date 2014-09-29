//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "HEMProgressNavigationController.h"

@interface HEMWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation HEMWelcomeViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[self navigationController] isKindOfClass:[HEMProgressNavigationController class]]) {
        HEMProgressNavigationController* pNav = (HEMProgressNavigationController*)[self navigationController];
        [pNav setNumberOfScreens:[[segue identifier] isEqualToString:@"signup"]?9:1];
    }

}

@end
