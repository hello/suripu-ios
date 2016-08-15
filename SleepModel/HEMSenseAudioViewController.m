//
//  HEMSenseAudioViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENAPIPreferences.h>
#import <SenseKit/SENPreference.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSenseAudioViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSenseAudioViewController()

@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *enableButton;

@end

@implementation HEMSenseAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [self trackAnalyticsEvent:HEMAnalyticsEventAudio];
}

- (void)configureButtons {
    [self enableBackButton:NO];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.enhanced-audio", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropAudio];
    [[self skipButton] setTitleColor:[UIColor tintColor]
                            forState:UIControlStateNormal];
    [[[self skipButton] titleLabel] setFont:[UIFont button]];
}

- (void)next {
    [[HEMOnboardingService sharedService] saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard audioToSetupSegueIdentifier]
                              sender:self];
}

#pragma mark - Actions

- (IBAction)skip:(id)sender {
    [self next];
}

- (IBAction)enable:(id)sender {
    // per design, this will be a non-blocking activity so we will fire and proceed
    SENPreference* preference = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
    [preference saveLocally];
    [SENAPIPreferences updatePreferencesWithCompletion:nil];
    [self next];
}

@end
