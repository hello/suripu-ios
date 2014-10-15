//
//  HEMSecondPillSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

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
}

- (void)setupDescription {
    NSString* firstPara = NSLocalizedString(@"second-pill.description.pairing-mode", nil);
    NSString* askThenGo = [NSString stringWithFormat:@"\n\n%@ ",
                           NSLocalizedString(@"second-pill.description.ask-to-pair", nil)];
    NSString* senseSettings = NSLocalizedString(@"second-pill.description.sense-settings", nil);
    NSString* andTap = [NSString stringWithFormat:@" %@ ",
                        NSLocalizedString(@"second-pill.description.and-tap", nil)];
    NSString* intoPairing = NSLocalizedString(@"second-pill.description.put-into-pairing", nil);
    NSString* senseGlow = [NSString stringWithFormat:@"\n\n%@ ",
                           NSLocalizedString(@"second-pill.description.sense-glow", nil)];
    NSString* purple = NSLocalizedString(@"onboarding.purple", nil);
    NSString* whenInMode = [NSString stringWithFormat:@" %@",
                            NSLocalizedString(@"second-pill.description.when-in-mode", nil)];
    
    NSMutableAttributedString* attrDesc
        = [[NSMutableAttributedString alloc] initWithString:firstPara];
    [attrDesc appendAttributedString:[[NSAttributedString alloc] initWithString:askThenGo]];
    [attrDesc appendAttributedString:[HEMOnboardingUtils boldAttributedText:senseSettings]];
    [attrDesc appendAttributedString:[[NSAttributedString alloc] initWithString:andTap]];
    [attrDesc appendAttributedString:[HEMOnboardingUtils boldAttributedText:intoPairing]];
    [attrDesc appendAttributedString:[[NSAttributedString alloc] initWithString:senseGlow]];
    [attrDesc appendAttributedString:[HEMOnboardingUtils boldAttributedText:purple
                                                                  withColor:[HelloStyleKit purple]]];
    [attrDesc appendAttributedString:[[NSAttributedString alloc] initWithString:whenInMode]];
    
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
    
}

@end
