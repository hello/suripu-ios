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
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMBeforeSleepViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *scrollableView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (copy, nonatomic) NSString* nextSegueId;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [self setup];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseColors];
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

- (IBAction)next:(id)sender {
    // FIXME (jimmy): work with design to see how Room Check actually can work on
    // a iphone 4 screen size.  currently, it looks like shit.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString* nextSegueId = [HEMOnboardingStoryboard beforeSleeptoRoomCheckSegueIdentifier];
    if (CGRectGetHeight(screenBounds) == kHEMIPhone4Height) {
        nextSegueId = [HEMOnboardingStoryboard beforeSleepToAlarmSegueIdentifier];
    }
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

@end
