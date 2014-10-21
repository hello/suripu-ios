//
//  HEMSecondPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSecondPillSetupViewController.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSecondPillSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonWidthConstraint;

@end

@implementation HEMSecondPillSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDescription];
    [SENAnalytics track:kHEMAnalyticsEventOnBAddPill];
}

- (void)setupDescription {
    NSString* descFormat = NSLocalizedString(@"second-pill.description.format", nil);
    NSString* senseSettings = NSLocalizedString(@"second-pill.description.sense-settings", nil);
    NSString* intoPairing = NSLocalizedString(@"second-pill.description.put-into-pairing", nil);
    NSString* purple = NSLocalizedString(@"onboarding.purple", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:senseSettings],
        [HEMOnboardingUtils boldAttributedText:intoPairing],
        [HEMOnboardingUtils boldAttributedText:purple
                                     withColor:[HelloStyleKit purple]]
    ];
    
    NSMutableAttributedString* attrDesc
        = [[NSMutableAttributedString alloc] initWithFormat:descFormat args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self descLabel] setAttributedText:attrDesc];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    if (![HEMBluetoothUtils stateAvailable]) {
        [[self continueButton] showActivityWithWidthConstraint:[self continueButtonWidthConstraint]];
        [self performSelector:@selector(next:)
                   withObject:sender
                   afterDelay:0.1f];
        return;
    }
    
    [[self continueButton] stopActivity];
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard secondPillNeedBleSegueIdentifier]
        : [HEMOnboardingStoryboard secondPillToSenseSegueIdentifier];
    [self performSegueWithIdentifier:segueId sender:self];
}

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

@end
