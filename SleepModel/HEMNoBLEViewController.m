//
//  HEMNoBLEViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMNoBLEViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"

@interface HEMNoBLEViewController ()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonWidthConstraint;

@end

@implementation HEMNoBLEViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubtitleText];
    [self updateContinueState];
}

- (void)setupSubtitleText {
    NSString* firstParagraph = NSLocalizedString(@"no-bluetooth.subtitle.ble-required", nil);
    NSString* launch = [NSString stringWithFormat:@"\n\n%@ ", NSLocalizedString(@"no-bluetooth.launch-the", nil)];
    NSString* settings = NSLocalizedString(@"no-bluetooth.settings", nil);
    NSString* appTap = [NSString stringWithFormat:@" %@ ",
                        NSLocalizedString(@"no-bluetooth.app-tap", nil)];
    NSString* bluetooth = NSLocalizedString(@"no-bluetooth.bluetooth", nil);
    NSString* flipSwitch = [NSString stringWithFormat:@" %@ ", NSLocalizedString(@"no-bluetooth.flip-switch", nil)];
    NSString* on = NSLocalizedString(@"no-bluetooth.on", nil);

    NSMutableAttributedString* attrSubtitle =
        [[NSMutableAttributedString alloc] initWithString:firstParagraph];
    
    [attrSubtitle appendAttributedString:[[NSAttributedString alloc] initWithString:launch]];
    [attrSubtitle appendAttributedString:[HEMOnboardingUtils boldAttributedText:settings]];
    [attrSubtitle appendAttributedString:[[NSAttributedString alloc] initWithString:appTap]];
    [attrSubtitle appendAttributedString:[HEMOnboardingUtils boldAttributedText:bluetooth]];
    [attrSubtitle appendAttributedString:[[NSAttributedString alloc] initWithString:flipSwitch]];
    [attrSubtitle appendAttributedString:[HEMOnboardingUtils boldAttributedText:on]];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self updateContinueState];
}

- (void)updateContinueState {
    if (![HEMBluetoothUtils stateAvailable]) {
        [[self continueButton] showActivityWithWidthConstraint:[self continueButtonWidthConstraint]];
        [self performSelector:@selector(updateContinueState)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    [[self continueButton] setEnabled:[HEMBluetoothUtils isBluetoothOn]];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

@end
