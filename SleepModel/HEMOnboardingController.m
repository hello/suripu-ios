    //
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMOnboardingController.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "HEMBaseController+Protected.h"

@interface HEMOnboardingController()

@property (strong, nonatomic) UIBarButtonItem* leftBarItem;

@end

@implementation HEMOnboardingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTitle];
}

- (void)configureTitle {
    [[self titleLabel] setTextColor:[HelloStyleKit onboardingTitleColor]];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
}

#pragma mark - navigation

- (void)enableBackButton:(BOOL)enable {
    if (enable) {
        if ([self leftBarItem] != nil) {
            [[self navigationItem] setLeftBarButtonItem:[self leftBarItem]];
        }
    } else {
        [self setLeftBarItem:[[self navigationItem] leftBarButtonItem]];
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
    
    [[self navigationItem] setHidesBackButton:!enable];
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:enable];
}

@end
