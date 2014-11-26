//
//  HEMBeforeSleepViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMBeforeSleepViewController.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"

@interface HEMBeforeSleepViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *scrollableView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setup];
}

- (void)setup {
    [[self scrollableView] addTitle:NSLocalizedString(@"onboarding.title.before-sleep", nil)];
    [[self scrollableView] addImage:[HelloStyleKit senseGlow]];
    [[self scrollableView] addDescription:[self attributedDescription]];
    
    [HEMOnboardingUtils applyShadowToButtonContainer:[self buttonContainer]];
}

- (NSAttributedString*)attributedDescription {
    NSString* descFormat = NSLocalizedString(@"onboarding.before-sleep.description.format", nil);
    NSString* green = NSLocalizedString(@"onboarding.green", nil);
    NSString* orange = NSLocalizedString(@"onboarding.orange", nil);
    NSString* red = NSLocalizedString(@"onboarding.red", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:green withColor:[UIColor greenColor]],
        [HEMOnboardingUtils boldAttributedText:orange withColor:[UIColor orangeColor]],
        [HEMOnboardingUtils boldAttributedText:red withColor:[UIColor redColor]]
    ];
    
    NSMutableAttributedString* attrDesc =
        [[NSMutableAttributedString alloc] initWithFormat:descFormat args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrDesc];
    
    return attrDesc;
}

@end
