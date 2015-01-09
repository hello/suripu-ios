//
//  HEMNoBLEViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMNoBLEViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMActionButton.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"

@interface HEMNoBLEViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bluetoothImageTopConstraint;

@end

@implementation HEMNoBLEViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setupSubtitleText];
    
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

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self checkBluetooth];
}

- (void)checkBluetooth {
    // if this controller is left on the stack, this controller is called and if
    // bluetooth is on, it will push the next controller on to the stack again
    if ([[self navigationController] topViewController] != self) return;
    
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(checkBluetooth)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    if ([HEMBluetoothUtils isBluetoothOn]) {
        [self next];
    }
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    
#if TARGET_IPHONE_SIMULATOR
    // If using the simulator, the help button will just simply let you proceed
    // because it doesn't have BLE anyways.
    [self next];
#else
    [HEMSupportUtil openHelpFrom:self];
#endif
    
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard noBleToBirthdaySegueIdentifier]
                              sender:self];
}

@end
