//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerController.h>
#import "UIView+HEMMotionEffects.h"

#import "UIFont+HEMStyle.h"

#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "HEMAnimationUtils.h"
#import "HEMSignUpViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"
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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getStartedCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noSenseCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playCenterYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgCenterXConstraint;

@property (strong, nonatomic) UIView* videoContainer;
@property (strong, nonatomic) MPMoviePlayerController* videoPlayer;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setupVideoPlayer];
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
    [HEMSupportUtil openURL:kHEMSenseOrderURL from:self];
}

- (IBAction)cancelGettingStarted:(id)sender {
    [self showGettingStartedActions:@(NO)];
}

#pragma mark - Video

- (void)setupVideoPlayer {
    // NOTE: MPMoviePlayer is a PoS!  PoS reason #1
    // if you try to set movieController fullScreen or controlstyle as full screen,
    // it will randomly crash the app when you play it, stating:
    // 'An AVPlayerItem cannot be associated with more than one instance of AVPlayer'
    // DON'T SET FULL SCREEN PROGRAMMATICALLY!  anything that says fullScreen, whatever
    // it is, DON'T DO IT!
    //
    // NOTE #2: MPMoviePlayerController is not a view controller.  There is a MPMoviePlayerViewController,
    // but that simply just wraps the MPMoviePlayerController by adding the it's view to the view controller's
    // view.  I'm not using the view controller b/c Kevin wants to eventually do something fancier and
    // [self presentMoviePlayerViewControllerAnimated:] which is an actual method, is absolutely not what
    // we want according to Kevin and James.
    //
    NSURL* introductoryVideoURL = [NSURL URLWithString:NSLocalizedString(@"video.url.intro", nil)];
    MPMoviePlayerController* movieController =
        [[MPMoviePlayerController alloc] initWithContentURL:introductoryVideoURL];
    [movieController setAllowsAirPlay:YES];
    [movieController setShouldAutoplay:YES];
    [movieController setMovieSourceType:MPMovieSourceTypeFile];
    [self setVideoPlayer:movieController];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(videoFinished:)
                   name:MPMoviePlayerPlaybackDidFinishNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(videoDidExitFullScreen:)
                   name:MPMoviePlayerDidExitFullscreenNotification
                 object:nil];
}

- (void)videoFinished:(NSNotification*)notification {
    NSNumber* reason = [notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        // PoS reason #3?  MPMovieFinishReasonUserExited does not seem to ever be returned, anywhere.
        // some stackoverflows mention this to be set as the reason in a WillExitFullScreenNotificaiton,
        // but it's not there or the notification never fires
        case MPMovieFinishReasonUserExited:
        case MPMovieFinishReasonPlaybackEnded:
            [self stopVideo];
            break;
        case MPMovieFinishReasonPlaybackError: {
            [self stopVideo];
            [self showMessageDialog:NSLocalizedString(@"video.error.playback-failed", nil)
                              title:NSLocalizedString(@"video.error.title", nil)];
            break;
        }
        default:
            break;
    }
}

- (void)videoDidExitFullScreen:(NSNotification*)notification {
    // NOTE: MPMoviePlayer is a PoS!  PoS reason #2
    // minimize and done button BOTH fires this notification with no information
    // to distinguish between the two events. For now, we will simply stop and
    // hide the video until we create a custom video player or add custom controls
    // based on design.  Since we simply just want to add the video in for now,
    // we will stick with this and be aware of this annoying fact.
    [self stopVideo];
}

- (IBAction)playVideo:(id)sender {
    if ([self videoContainer] == nil) {
        [self setVideoContainer:[[UIView alloc] initWithFrame:[[self view] bounds]]];
    }
    [[[self videoPlayer] view] setAlpha:1.0f];
    [[self videoContainer] setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.0f]];
    [[self videoContainer] setAlpha:1.0f];
    
    [[self view] addSubview:[self videoContainer]];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [[self videoContainer] setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
                     }
                     completion:^(BOOL finished) {
                         [[self videoPlayer] prepareToPlay];
                         [[[self videoPlayer] view] setFrame:[[self videoContainer] bounds]];
                         [[self videoContainer] addSubview:[[self videoPlayer] view]];
                         [[self videoPlayer] play];
                     }];
}

- (void)stopVideo {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [[[self videoPlayer] view] setAlpha:0.0f];
                         [[self videoContainer] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self videoPlayer] stop];
                         [[[self videoPlayer] view] removeFromSuperview];
                         [[self videoContainer] removeFromSuperview];
                     }];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
