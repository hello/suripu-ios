//
//  HEMTwoPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTwoPillSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"

@interface HEMTwoPillSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *firstPillButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstPillButtonWidthConstraint;

@end

@implementation HEMTwoPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubtitleText];
}

- (void)setSubtitleText {
    NSString* text = NSLocalizedString(@"two-pill-setup.subtitle", nil);
    
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self subtitleLabel] setAttributedText:attrText];
}

#pragma mark

- (IBAction)setupFirstPill:(id)sender {
    if (![HEMBluetoothUtils stateAvailable]) {
        NSLayoutConstraint* constraint = [self firstPillButtonWidthConstraint];
        [[self firstPillButton] showActivityWithWidthConstraint:constraint];
        [self performSelector:@selector(setupFirstPill:)
                   withObject:sender
                   afterDelay:0.1f];
        return;
    }
    
    [[self firstPillButton] stopActivity];
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard pillNeedBluetoothSegueIdentifier]
        : [HEMOnboardingStoryboard firstPillSenseSetupSegueIdentifier];
    [self performSegueWithIdentifier:segueId sender:self];
}

- (IBAction)setupSecondPill:(id)sender {
    
}

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

@end
