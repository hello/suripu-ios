//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import "UIView+HEMMotionEffects.h"

#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "HEMProgressNavigationController.h"
#import "HEMAnimationUtils.h"
#import "HEMSignUpViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"

static CGFloat const kHEMWelcomeButtonAnimationDuration = 0.5f;
static CGFloat const kHEMWelcomeButtonDelayIncrements = 0.15f;
static NSInteger const kHEMWelcomeNumberOfSignupScreens = 9;

@interface HEMWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UIButton *noSenseButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelGetStartedButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSenseCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playCenterYConstraint;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSubtitleText];
    
    UIColor* whiteColor = [UIColor whiteColor];
    CGColorRef white = [whiteColor CGColor];
    
    [[self getStartedButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    [[self signinButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    [[self signupButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    [[[self getStartedButton] layer] setBorderColor:white];
    [[[self signinButton] layer] setBorderColor:white];
    [[[self signupButton] layer] setBorderColor:white];
    
    CGFloat width = CGRectGetWidth([[self view] bounds]);
    [[self loginCenterXConstraint] setConstant:-width];
    [[self signupCenterXConstraint] setConstant:-width];
    [[self cancelCenterXConstraint] setConstant:-width];
 
    [[self bgImageView] add3DEffectWithBorder:5.0f];
    
}

- (void)setSubtitleText {
    NSString* text = NSLocalizedString(@"welcome.subtitle", nil);
    
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self subtitleLabel] setAttributedText:attrText];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -30.0f;
    [self updateConstraint:[self playCenterYConstraint] withDiff:diff];
}

#pragma mark - Animations

- (void)showGettingStartedActions:(NSNumber*)showValue {
    BOOL show = [showValue boolValue];
    CGFloat alpha = 0.0f;
    CGFloat xConstant = -CGRectGetWidth([[self view] bounds]);
    NSString* timingFunction = kCAMediaTimingFunctionEaseIn;
    
    if (show) {
        timingFunction = kCAMediaTimingFunctionEaseOut;
        alpha = 1.0f;
        xConstant = 1.0f;
        
        [[self signinButton] setHidden:NO];
        [[self signupButton] setHidden:NO];
        [[self cancelGetStartedButton] setHidden:NO];
    }
    
    [HEMAnimationUtils transactAnimation:^{
        // why not use CABasicAnimations here?  well it's because those do not
        // work with autolayout constraints :(
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             [[self signinButton] setAlpha:alpha];
                             [[self loginCenterXConstraint] setConstant:xConstant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             [[self signupButton] setAlpha:alpha];
                             [[self signupCenterXConstraint] setConstant:xConstant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements*2
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             [[self cancelGetStartedButton] setAlpha:alpha];
                             [[self cancelCenterXConstraint] setConstant:xConstant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
    } completion:^{
        if (!show) {
            [[self signinButton] setHidden:YES];
            [[self signupButton] setHidden:YES];
            [[self cancelGetStartedButton] setHidden:YES];
        }
    } timing:timingFunction];
    
    if (!show) {
        [self performSelector:@selector(showInitialActions:)
                   withObject:@(YES)
                   afterDelay:kHEMWelcomeButtonDelayIncrements*2];
    }
}

- (void)showInitialActions:(NSNumber*)showValue {
    BOOL show = [showValue boolValue];
    CGFloat constant = CGRectGetWidth([[self view] bounds]);
    CGFloat alpha = 0.0f;
    NSString* timingFunction = kCAMediaTimingFunctionEaseIn;
    NSString* title = NSLocalizedString(@"welcome.title.get-started", nil);
    
    if (show) {
        alpha = 1.0f;
        constant = 0.0f;
        timingFunction = kCAMediaTimingFunctionEaseOut;
        title = NSLocalizedString(@"welcome.title.meet-sense", nil);
        
        [[self getStartedButton] setHidden:NO];
        [[self noSenseButton] setHidden:NO];
        [[self playButton] setHidden:NO];
    }
    
    [[self titleLabel] setText:title];
    
    [HEMAnimationUtils transactAnimation:^{
        // why not use CABasicAnimations here?  well it's because those do not
        // work with autolayout constraints :(
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             [[self getStartedButton] setAlpha:alpha];
                             [[self getStartedCenterXConstraint] setConstant:constant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             [[self noSenseButton] setAlpha:alpha];
                             [[self noSenseCenterXConstraint] setConstant:constant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonDelayIncrements +
                                    kHEMWelcomeButtonAnimationDuration
                         animations:^{
                             [[self playButton] setAlpha:alpha];
                             [[self subtitleLabel] setAlpha:alpha];
                         }
                         completion:nil];
    } completion:^{
        if (!show) {
            [[self getStartedButton] setHidden:YES];
            [[self noSenseButton] setHidden:YES];
            [[self playButton] setHidden:YES];
        }
    } timing:timingFunction];

    if (!show) {
        [self performSelector:@selector(showGettingStartedActions:)
                   withObject:@(YES)
                   afterDelay:kHEMWelcomeButtonDelayIncrements];
    }
}

#pragma mark - Actions

- (IBAction)getStarted:(id)sender {
    [self showInitialActions:@(NO)];
}

- (IBAction)getSense:(id)sender {
    // TODO (jimmy): likely going to be building an embedded / in-app browser
    // when we have time so not going to do anything fancier than push people out
    NSURL* orderURL = [NSURL URLWithString:kHEMSenseOrderURL];
    [[UIApplication sharedApplication] openURL:orderURL];
}

- (IBAction)cancelGettingStarted:(id)sender {
    [self showGettingStartedActions:@(NO)];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[self navigationController] isKindOfClass:[HEMProgressNavigationController class]]) {
        HEMProgressNavigationController* pNav = (HEMProgressNavigationController*)[self navigationController];
        UIViewController* rootVC = [[pNav viewControllers] firstObject];
        NSInteger numberOfSteps = 1;
        if ([rootVC isKindOfClass:[HEMSignUpViewController class]]) {
            numberOfSteps = kHEMWelcomeNumberOfSignupScreens;
        }
        [pNav setNumberOfScreens:numberOfSteps];
    }
    
}

@end
