//
//  HEMResetDoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMResetDoneViewController.h"

@implementation HEMResetDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
}

- (IBAction)finish:(id)sender {
    [self completeOnboarding];
}

@end
