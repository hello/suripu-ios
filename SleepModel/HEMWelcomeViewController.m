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
#import "HEMAnimationUtils.h"
#import "HEMSignUpViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"

static CGFloat const kHEMWelcomeMotionEffectBorder = 10.0f;
static CGFloat const kHEMWelcomeButtonAnimationDuration = 0.5f;
static CGFloat const kHEMWelcomeButtonDelayIncrements = 0.15f;

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgCenterXConstraint;

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
 
    [[self bgImageView] add3DEffectWithBorder:kHEMWelcomeMotionEffectBorder];
    
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
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self signinButton] setAlpha:alpha];
                             [[self loginCenterXConstraint] setConstant:xConstant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self signupButton] setAlpha:alpha];
                             [[self signupCenterXConstraint] setConstant:xConstant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements*2
                            options:UIViewAnimationOptionBeginFromCurrentState
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

- (void)updateTtitle:(NSString*)text alignment:(NSTextAlignment)alignment {
    CGFloat halfDuration = kHEMWelcomeButtonAnimationDuration/2;
    [UIView animateWithDuration:halfDuration
                     animations:^{
                         [[self titleLabel] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self titleLabel] setTextAlignment:alignment];
                         [[self titleLabel] setText:text];
                         [UIView animateWithDuration:halfDuration
                                          animations:^{
                                              [[self titleLabel] setAlpha:1.0f];
                                          }];
                     }];
}

- (void)showInitialActions:(NSNumber*)showValue {
    BOOL show = [showValue boolValue];
    CGFloat constant = CGRectGetWidth([[self view] bounds]);
    CGFloat alpha = 0.0f;
    CGFloat bgXConstant = ((CGRectGetWidth([[self bgImageView] bounds]) - constant)/2)
                            - kHEMWelcomeMotionEffectBorder;
    NSString* timingFunction = kCAMediaTimingFunctionEaseIn;
    NSString* title = NSLocalizedString(@"welcome.title.welcome", nil);
    NSTextAlignment alignment = NSTextAlignmentCenter;
    
    if (show) {
        alpha = 1.0f;
        bgXConstant = -(bgXConstant);
        constant = 0.0f;
        timingFunction = kCAMediaTimingFunctionEaseOut;
        alignment = NSTextAlignmentLeft;
        title = NSLocalizedString(@"welcome.title.meet-sense", nil);
        
        [[self getStartedButton] setHidden:NO];
        [[self noSenseButton] setHidden:NO];
        [[self playButton] setHidden:NO];
    }
    
    [HEMAnimationUtils transactAnimation:^{
        [self updateTtitle:title alignment:alignment];
        // why not use CABasicAnimations here?  well it's because those do not
        // work with autolayout constraints :(
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self getStartedButton] setAlpha:alpha];
                             [[self getStartedCenterXConstraint] setConstant:constant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self noSenseButton] setAlpha:alpha];
                             [[self noSenseCenterXConstraint] setConstant:constant];
                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonDelayIncrements +
                                    kHEMWelcomeButtonAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self playButton] setAlpha:alpha];
                             [[self subtitleLabel] setAlpha:alpha];
                             [[self bgCenterXConstraint] setConstant:bgXConstant];
                             [[self view] layoutIfNeeded];
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

@end
