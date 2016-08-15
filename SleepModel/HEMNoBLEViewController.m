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
#import "HEMSensePairViewController.h"
#import "HEMBluetoothUtils.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"

static NSUInteger const HEMNoBLEMaxCheckAttempts = 10;

@interface HEMNoBLEViewController ()

@property (weak, nonatomic) IBOutlet UILabel *instructionView;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UILabel *step1DescLabel;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UILabel *step2DescLabel;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UILabel *step3DescLabel;

@property (assign, nonatomic) NSUInteger checkAttempts;

@end

@implementation HEMNoBLEViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.turn-on-ble", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropBluetooth];
    [self configureSteps];
    [self trackAnalyticsEvent:HEMAnalyticsEventNoBle];
}

- (void)configureSteps {
    UIFont* font = [UIFont bluetoothStepsFont];
    [[self step1Label] setFont:font];
    [[self step1DescLabel] setFont:font];
    [[self step2Label] setFont:font];
    [[self step2DescLabel] setFont:font];
    [[self step3Label] setFont:font];
    [[self step3DescLabel] setFont:font];
}

- (void)viewDidBecomeActive {
    [super viewDidBecomeActive];
    [self setCheckAttempts:0];
    [self checkBluetooth];
}

- (void)checkBluetooth {
    // if this controller is left on the stack, this controller is called and if
    // bluetooth is on, it will push the next controller on to the stack again
    if ([[self navigationController] topViewController] != self) return;
    
    if (![HEMBluetoothUtils isBluetoothOn]) {
        if ([self checkAttempts] < HEMNoBLEMaxCheckAttempts) {
            DDLogVerbose(@"ble not on, check again in a few ms");
            [self performSelector:@selector(checkBluetooth)
                       withObject:nil
                       afterDelay:0.1f];
            [self setCheckAttempts:[self checkAttempts] + 1];
        }
        return;
    } else {
        [self next];
    }
}

- (void)next {
    if ([self flow]) {
        UIViewController* nextVC = [[self flow] controllerToSwapInAfterViewController:self];
        if (nextVC) {
            [[self navigationController] setViewControllers:@[nextVC] animated:YES];
        } else {
            NSString* nextSegue = [[self flow] nextSegueIdentifierAfterViewController:self];
            [self performSegueWithIdentifier:nextSegue sender:nil];
        }
    } else if (![self delegate]) {
        NSString* nextSegue = [HEMOnboardingStoryboard noBleToBirthdaySegueIdentifier];
        [self performSegueWithIdentifier:nextSegue sender:self];
    } else {
        [[self delegate] bleDetectedFrom:self];
    }
}

@end
