//
//  HEMSenseSetupViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

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
    [self setupDescription];
}

- (void)setupDescription {
    NSString* plugInSenseToGlow = [NSString stringWithFormat:@"%@ ",
                                   NSLocalizedString(@"sense-setup.description.plug-n-glow", nil)];
    NSString* purple = NSLocalizedString(@"onboarding.purple", nil);
    NSString* onAndReady = [NSString stringWithFormat:@" %@",
                            NSLocalizedString(@"sense-setup.description.on-and-ready", nil)];
    
    NSMutableAttributedString* attrText
        = [[NSMutableAttributedString alloc] initWithString:plugInSenseToGlow];
    [attrText appendAttributedString:[HEMOnboardingUtils boldAttributedText:purple
                                                                  withColor:[HelloStyleKit purple]]];
    [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:onAndReady]];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self descriptionLabel] setAttributedText:attrText];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
}

@end
