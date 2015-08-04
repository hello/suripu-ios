//
//  HEMSensePairingModeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSensePairingModeViewController.h"
#import "HEMActionButton.h"

@interface HEMSensePairingModeViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSensePairingModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-pairing-mode", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSensePairingMode];
    [self configureAttributedSubtitle];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairingMode];
}

- (void)configureAttributedSubtitle {
    NSString* format = NSLocalizedString(@"onboarding.sense.pairing-mode.format", nil);
    NSString* onTop = NSLocalizedString(@"onboarding.sense.pairing-mode.directly-on-top", nil);
    NSArray* args = @[[self boldAttributedText:onTop]];
    
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    
    [self applyCommonDescriptionAttributesTo:attrSubtitle];
    [[self descriptionLabel] setAttributedText:attrSubtitle];
}

- (IBAction)done:(id)sender {
    // just go back to Sense Pairing
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
