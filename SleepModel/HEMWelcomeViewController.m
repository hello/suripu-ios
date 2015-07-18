//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "UIView+HEMMotionEffects.h"

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "HEMAnimationUtils.h"
#import "HEMSignUpViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMSupportUtil.h"

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSenseCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playCenterYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgCenterXConstraint;

@property (assign, nonatomic) CGFloat origGetStartedLeadingConstant;
@property (assign, nonatomic) CGFloat origGetStartedTrailingConstant;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setLeftBarButtonItem:nil];
    
    [self configureTitle];
    [self configureSubtitle];
    [self configureButtonStyles];
    [self configureDefaultConstraints];
 
    [[self bgImageView] add3DEffectWithBorder:kHEMWelcomeMotionEffectBorder];
}

- (void)configureTitle {
    [[self titleLabel] setTextColor:[UIColor whiteColor]];
    [[self titleLabel] setFont:[UIFont onboardingTitleLargeFont]];
}

- (void)configureDefaultConstraints {
    CGFloat width = CGRectGetWidth([[self view] bounds]);
    [[self loginCenterXConstraint] setConstant:-width];
    [[self signupCenterXConstraint] setConstant:-width];
    [[self cancelCenterXConstraint] setConstant:-width];
    
    [self setOrigGetStartedLeadingConstant:[[self getStartedLeadingConstraint] constant]];
    [self setOrigGetStartedTrailingConstant:[[self getStartedTrailingConstraint] constant]];
}

- (void)configureButtonStyles {
    CGFloat borderWidth = 2.0f;
    UIColor* bgColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    UIColor* whiteColor = [UIColor whiteColor];
    CGColorRef white = [whiteColor CGColor];
    
    [[self getStartedButton] setBackgroundColor:bgColor];
    [[self getStartedButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    
    [[self signinButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    [[self signinButton] setBackgroundColor:bgColor];
    
    [[self signupButton] setTitleColor:whiteColor forState:UIControlStateNormal];
    [[self signupButton] setBackgroundColor:bgColor];
    
    [[[self getStartedButton] layer] setBorderWidth:borderWidth];
    [[[self getStartedButton] layer] setBorderColor:white];
    [[[self signinButton] layer] setBorderWidth:borderWidth];
    [[[self signinButton] layer] setBorderColor:white];
    [[[self signupButton] layer] setBorderColor:white];
    [[[self signupButton] layer] setBorderWidth:borderWidth];
    
    [[[self noSenseButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [[[self cancelGetStartedButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
}

- (void)configureSubtitle {
    NSString* text = NSLocalizedString(@"welcome.subtitle", nil);
    
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttributes:@{NSFontAttributeName : [UIFont onboardingDescriptionLargeFont],
                              NSForegroundColorAttributeName : [UIColor whiteColor]}
                      range:NSMakeRange(0, [attrText length])];
    
    [[self subtitleLabel] setAttributedText:attrText];
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
    CGFloat width = CGRectGetWidth([[self view] bounds]);
    CGFloat getStartedLeadConstant = -width + [self origGetStartedLeadingConstant];
    CGFloat getStartedTrailConstant = width + [self origGetStartedTrailingConstant];
    CGFloat noSenseConstant = width;
    CGFloat alpha = 0.0f;
    CGFloat bgXConstant = ((CGRectGetWidth([[self bgImageView] bounds]) - noSenseConstant)/2)
                            - kHEMWelcomeMotionEffectBorder;
    NSString* timingFunction = kCAMediaTimingFunctionEaseIn;
    NSString* title = NSLocalizedString(@"welcome.title.welcome", nil);
    NSTextAlignment alignment = NSTextAlignmentCenter;
    
    if (show) {
        alpha = 1.0f;
        bgXConstant = -(bgXConstant);
        getStartedLeadConstant = [self origGetStartedLeadingConstant];
        getStartedTrailConstant = [self origGetStartedTrailingConstant];
        noSenseConstant = 0.0f;
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
                            
                             // order matters, otherwise logs will show constraints
                             // being broken
                             if (!show) {
                                 [[self getStartedLeadingConstraint] setConstant:getStartedLeadConstant];
                                 [[self getStartedTrailingConstraint] setConstant: getStartedTrailConstant];
                             } else {
                                 [[self getStartedTrailingConstraint] setConstant: getStartedTrailConstant];
                                 [[self getStartedLeadingConstraint] setConstant:getStartedLeadConstant];
                             }

                             [[self view] layoutIfNeeded];
                         }
                         completion:nil];
        
        [UIView animateWithDuration:kHEMWelcomeButtonAnimationDuration
                              delay:kHEMWelcomeButtonDelayIncrements
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [[self noSenseButton] setAlpha:alpha];
                             
                             [[self noSenseCenterXConstraint] setConstant:noSenseConstant];
                             
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
    [HEMSupportUtil openOrderFormFrom:self];
    [SENAnalytics track:kHEMAnalyticsEventOnBNoSense];
}

- (IBAction)cancelGettingStarted:(id)sender {
    [self showGettingStartedActions:@(NO)];
}

- (IBAction)playVideo:(id)sender {
    NSURL* introductoryVideoURL = [NSURL URLWithString:NSLocalizedString(@"video.url.intro", nil)];
    MPMoviePlayerViewController* videoPlayer
        = [[MPMoviePlayerViewController alloc] initWithContentURL:introductoryVideoURL];
    [self presentMoviePlayerViewControllerAnimated:videoPlayer];
    [SENAnalytics track:kHEMAnalyticsEventVideo];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
