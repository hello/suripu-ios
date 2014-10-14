//
//  HEMSenseSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSenseSetupViewController.h"
#import "HEMActionButton.h"

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *senseDiagram;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
    CGSize constraint = CGSizeZero;
    constraint.width = CGRectGetWidth([[self descriptionLabel] bounds]);
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self descriptionLabel] sizeThatFits:constraint];
    DLog(@"text height %f", textSize.height);
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    
}

@end
