//
//  HEMNoBLEViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMNoBLEViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"

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
    
    [SENAnalytics track:kHEMAnalyticsEventOnBNoBle];
}

- (void)setupSubtitleText {
    NSString* subtitleFormat = NSLocalizedString(@"no-bluetooth.subtitle.format", nil);
    NSString* settings = NSLocalizedString(@"no-bluetooth.settings", nil);
    NSString* bluetooth = NSLocalizedString(@"no-bluetooth.bluetooth", nil);
    NSString* on = NSLocalizedString(@"no-bluetooth.on", nil);

    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:settings],
        [HEMOnboardingUtils boldAttributedText:bluetooth],
        [HEMOnboardingUtils boldAttributedText:on]
    ];
    
    NSMutableAttributedString* attrSubtitle =
        [[NSMutableAttributedString alloc] initWithFormat:subtitleFormat args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize constraint = [[self subtitleLabel] bounds].size;
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self subtitleLabel] sizeThatFits:constraint];
    DDLogVerbose(@"get app subtitle height %f", textSize.height);
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
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    
#if TARGET_IPHONE_SIMULATOR
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard noBleToSetupSegueIdentifier]
                              sender:self];
#endif
}

@end
