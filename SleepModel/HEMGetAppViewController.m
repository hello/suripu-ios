//
//  HEMGetAppViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMGetAppViewController.h"
#import "HEMOnboardingUtils.h"

@interface HEMGetAppViewController ()

@end

@implementation HEMGetAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupDescription];
    
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBGetApp];
}

- (void)setupDescription {
    NSString* format = NSLocalizedString(@"setup.get-app.subtitle.format", nil);
    NSString* url = NSLocalizedString(@"setup.get-app.url", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:url withColor:[UIColor blackColor]]
    ];
    
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self descriptionLabel] setAttributedText:attrSubtitle];
}

- (IBAction)finish:(id)sender {
    [HEMOnboardingUtils finisOnboardinghWithMessageFrom:self];
}

@end
