//
//  HEMTwoPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMSecondPillCheckViewController.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMSecondPillSetupViewController.h"

@interface HEMSecondPillCheckViewController ()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *firstPillButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstPillButtonWidthConstraint;

@end

@implementation HEMSecondPillCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubtitleText];
    [SENAnalytics track:kHEMAnalyticsEventOnBSecondPillCheck];
}

- (void)setSubtitleText {
    NSString* text = NSLocalizedString(@"pairing.check.add-second-pill-subtitle", nil);
    
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:text];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self subtitleLabel] setAttributedText:attrText];
}

#pragma mark - Actions

- (IBAction)setupNewSense:(id)sender {
    [[self delegate] checkController:self isSettingUpNewSense:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[HEMSecondPillSetupViewController class]]) {
        HEMSecondPillSetupViewController* setupVC = (HEMSecondPillSetupViewController*)destVC;
        [setupVC setDelegate:[self delegate]]; // pass it along
    }
}

@end
