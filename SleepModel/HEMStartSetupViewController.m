//
//  HEMStartSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMStartSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"

@interface HEMStartSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *onePillButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *twoPillButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onePillWidthConstraint;

@property (assign, nonatomic) BOOL bluetoothOn;

@end

@implementation HEMStartSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [self setSubtitleText];
}

- (void)setSubtitleText {
    NSString* text = NSLocalizedString(@"get-started.subtitle", nil);
    
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self subtitleLabel] setAttributedText:attrText];
}

#pragma mark - Actions

- (IBAction)setupNewSense:(id)sender {
    if (![HEMBluetoothUtils stateAvailable]) {
        [[self onePillButton] showActivityWithWidthConstraint:[self onePillWidthConstraint]];
        [self performSelector:@selector(setupNewSense:)
                   withObject:sender
                   afterDelay:0.1f];
        return;
    }
    
    [[self onePillButton] stopActivity];
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard needBluetoothSegueIdentifier]
        : [HEMOnboardingStoryboard senseSetupSegueIdentifier];
    [self performSegueWithIdentifier:segueId sender:self];
}

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

@end
