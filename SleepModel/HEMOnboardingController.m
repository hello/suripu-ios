    //
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMOnboardingController.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMSupportUtil.h"

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

#pragma mark - Nav

- (void)showHelpButton {
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithTitle:@"?"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(help:)];
    [item setTitlePositionAdjustment:UIOffsetMake(-10.0f, 0.0f)
                       forBarMetrics:UIBarMetricsDefault];
    [item setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor],
        NSFontAttributeName : [UIFont helpButtonTitleFont]
    } forState:UIControlStateNormal];
    [[self navigationItem] setRightBarButtonItem:item];
}

- (void)help:(id)sender {
    [HEMSupportUtil openHelpFrom:self];
}

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
