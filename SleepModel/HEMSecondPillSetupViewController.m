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
#import "HEMActionButton.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[HEMUserDataCache sharedUserDataCache] setSettingUpSecondPill:NO];
}

- (void)setupDescription {
    NSString* descFormat = NSLocalizedString(@"second-pill.description.format", nil);
    NSString* senseSettings = NSLocalizedString(@"second-pill.description.sense-settings", nil);
    NSString* intoPairing = NSLocalizedString(@"second-pill.description.put-into-pairing", nil);
    NSString* blue = NSLocalizedString(@"onboarding.blue", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:senseSettings],
        [HEMOnboardingUtils boldAttributedText:intoPairing],
        [HEMOnboardingUtils boldAttributedText:blue
                                     withColor:[UIColor blueColor]]
    ];
    
    NSMutableAttributedString* attrDesc
        = [[NSMutableAttributedString alloc] initWithFormat:descFormat args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    [[self descLabel] setAttributedText:attrDesc];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): this controller has been decommissioned temporarily
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

@end
