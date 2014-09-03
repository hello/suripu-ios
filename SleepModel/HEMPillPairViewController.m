//
//  HEMPillPairViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMPillPairViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pillImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pillImageVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyButtonVSpaceConstraint;

@end

@implementation HEMPillPairViewController

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self pillImageVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyButtonVSpaceConstraint] withDiff:diff];
}

- (IBAction)pairPill:(id)sender {
    DLog(@"WARNING: pairing a pill has not yet been implemented!");
    // prevent user from going back to this screen
    UIViewController* dataIntroVC = [HEMOnboardingStoryboard instantiateDataIntroViewController];
    [[self navigationController] setViewControllers:@[dataIntroVC] animated:YES];
}

@end
