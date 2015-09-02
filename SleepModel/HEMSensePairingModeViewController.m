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
#import "HEMEmbeddedVideoView.h"

@interface HEMSensePairingModeViewController()

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView *videoView;

@end

@implementation HEMSensePairingModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVideoView];
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.sense-pairing-mode", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropSensePairingMode];
    [self configureAttributedSubtitle];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairingMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[self videoView] isReady]) {
        [[self videoView] setReady:YES];
    } else {
        [[self videoView] playVideoWhenReady];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self videoView] pause];
}

- (void)configureVideoView {
    UIImage* image = [UIImage imageNamed:@"pairingMode"];
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.pairing-mode", nil);
    [[self videoView] setFirstFrame:image videoPath:videoPath];
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
