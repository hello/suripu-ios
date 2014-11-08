//
//  HEMSenseSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSenseSetupViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"

@interface HEMSenseSetupViewController ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *senseDiagram;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@end

@implementation HEMSenseSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [self setupDescription];
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseSetup];
}

- (void)setupDescription {
    NSString* subtitle = NSLocalizedString(@"sense-setup.description", nil);

    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:subtitle];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self descriptionLabel] setAttributedText:attrText];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

@end
