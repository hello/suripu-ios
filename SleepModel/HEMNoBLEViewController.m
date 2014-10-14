//
//  HEMNoBLEViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMNoBLEViewController.h"

@interface HEMNoBLEViewController ()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation HEMNoBLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    CGSize constraint = CGSizeZero;
    constraint.width = CGRectGetWidth([[self subtitleLabel] bounds]);
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self subtitleLabel] sizeThatFits:constraint];
    DLog(@"text height %f", textSize.height);
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    
}

- (IBAction)help:(id)sender {
    
}

@end
