//
//  HEMEnablePushViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/9/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMEnablePushViewController.h"
#import "HEMActionButton.h"
#import "UIFont+HEMStyle.h"
#import "HEMOnboardingUtils.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMNotificationHandler.h"

@interface HEMEnablePushViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *enableButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMEnablePushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setupDescription];
}

- (void)setupDescription {
    NSString* description = NSLocalizedString(@"onboarding.push.description", nil);
    NSMutableAttributedString* attrDesc
        = [[NSMutableAttributedString alloc] initWithString:description];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    [[self descriptionLabel] setAttributedText:attrDesc];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize constraint = [[self descriptionLabel] bounds].size;
    constraint.height = MAXFLOAT;
    DDLogVerbose(@"text height %f", [[self descriptionLabel] sizeThatFits:constraint].height);
}

#pragma mark - Actions

- (IBAction)enableNotifications:(id)sender {
    [HEMNotificationHandler registerForRemoteNotifications];
    // don't wait before user to answer the dialog, just go
    [self next];
}

- (IBAction)skip:(id)sender {
    [self next];
}

#pragma mark -

- (void)next {
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(next)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard pushToNoBleSegueIdentifier]
        : [HEMOnboardingStoryboard pushToSenseSetupSegueIdentifier];
    
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:segueId sender:self];
}

@end
