//
//  HEMSleepQuestionFYIViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/26/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSleepQuestionFYIViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMActionButton.h"

@interface HEMSleepQuestionFYIViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *fyiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *okayButton;

@end

@implementation HEMSleepQuestionFYIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)okay:(id)sender {
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[HEMSettingsTableViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
