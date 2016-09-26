//
//  HEMVoiceTutorialPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSpeechResult.h>

#import "HEMVoiceTutorialPresenter.h"
#import "HEMScreenUtils.h"
#import "HEMVoiceService.h"
#import "HEMActionSheetViewController.h"
#import "HEMActionSheetTitleView.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"

static CGFloat const HEMVoiceTutorialInitialSenseScale = 0.6f;
static CGFloat const HEMVoiceTutorialAnimeDuration = 0.3f;
static CGFloat const HEMVoiceTutorialInProgressLaterBottomMargin = 21.0f;
static CGFloat const HEMVoiceTutorialInProgressTableAlpha = 0.4f;
static CGFloat const HEMVoiceTutorialInProgressRingAlpha = 0.07f;
static CGFloat const HEMVoiceTutorialInProgressOuterRingSize = 236.0f;
static CGFloat const HEMVoiceTutorialInProgressMiddleRingSize = 192.0f;
static CGFloat const HEMVoiceTutorialInProgressInnerRingSize = 146.0f;
static CGFloat const HEMVoiceTutorialRingAnimeDelay = 0.1f;
static CGFloat const HEMVoiceTutorialRingAnimeDuration = 0.75f;
static CGFloat const HEMVoiceTutorialResponseDuration = 2.0f;
static NSInteger const HEMVoiceTutorialFailureBeforeTip = 2;
static CGFloat const HEMVoiceTutorialMinContentTopSpacing = 32.0f;
static CGFloat const HEMVoiceTutorialMinContentTopSpacing4s = 64.0f;

@interface HEMVoiceTutorialPresenter()

@property (nonatomic, weak) UILabel* tryNowLabel;

@property (nonatomic, weak) UIView* voiceContentContainer;
@property (nonatomic, weak) UIView* speechLabelContainer;
@property (nonatomic, weak) UILabel* speechCommandLabel;
@property (nonatomic, weak) UILabel* speechErrorLabel;
@property (nonatomic, weak) NSLayoutConstraint* speechCommandBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* speechErrorBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* voiceContentCenterConstraint;

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UIButton* laterButton;
@property (nonatomic, weak) UIButton* continueButton;
@property (nonatomic, weak) UIImageView* senseImageView;
@property (nonatomic, weak) UIImageView* tableImageView;
@property (nonatomic, weak) NSLayoutConstraint* senseWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint* senseHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint* tableBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* laterButtonBottomConstraint;

@property (nonatomic, assign) CGFloat origLaterBottomMargin;
@property (nonatomic, assign) CGFloat origTableBottomMargin;

@property (nonatomic, weak) CAShapeLayer* outerSenseRing;
@property (nonatomic, weak) CAShapeLayer* middleSenseRing;
@property (nonatomic, weak) CAShapeLayer* innerSenseRing;

@property (nonatomic, strong) UIBarButtonItem* infoItem;
@property (nonatomic, weak) UINavigationItem* navItem;

@property (nonatomic, assign) NSInteger failures;

@property (nonatomic, weak) HEMVoiceService* voiceService;
@property (nonatomic, assign, getter=isInfoShowing) BOOL infoShowing;

@end

@implementation HEMVoiceTutorialPresenter

- (instancetype)initWithVoiceService:(HEMVoiceService*)voiceService {
    self = [super init];
    if (self) {
        _voiceService = voiceService;
        _failures = 0;
    }
    return self;
}

- (void)bindWithTryNowLabel:(UILabel*)tryNowLabel {
    [tryNowLabel setHidden:YES]; // initially, until user continues
    [self setTryNowLabel:tryNowLabel];
}

- (void)bindWithVoiceContentContainer:(UIView*)voiceContentContainer
                 withCenterConstraint:(NSLayoutConstraint*)centerConstraint {
    [self setVoiceContentContainer:voiceContentContainer];
    [self setVoiceContentCenterConstraint:centerConstraint];
}

- (void)bindWithSpeechLabelContainer:(UIView*)speechCommandContainer
                        commandLabel:(UILabel*)commandLabel
             commandBottomConstraint:(NSLayoutConstraint*)commandBottomConstraint
                          errorLabel:(UILabel*)errorLabel
               errorBottomConstraint:(NSLayoutConstraint*)errorBottomConstraint {
    UIFont* commandFont = [UIFont h4];
    if (HEMIsIPhone4Family() || HEMIsIPhone5Family()) {
        commandFont = [UIFont h5];
    }
    
    [commandLabel setFont:commandFont];
    [commandLabel setTextColor:[UIColor grey6]];
    [errorLabel setFont:commandFont];
    [errorLabel setTextColor:[UIColor grey6]];
    [speechCommandContainer setHidden:YES];
    
    [self setSpeechLabelContainer:speechCommandContainer];
    [self setSpeechCommandLabel:commandLabel];
    [self setSpeechCommandBottomConstraint:commandBottomConstraint];
    [self setSpeechErrorLabel:errorLabel];
    [self setSpeechErrorBottomConstraint:errorBottomConstraint];
}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {
    UIImage* infoImage = [UIImage imageNamed:@"infoIconSmall"];
    UIBarButtonItem* infoItem = [[UIBarButtonItem alloc] initWithImage:infoImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(voiceInfo)];
    [self setInfoItem:infoItem];
    [self setNavItem:navItem];
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithSenseImageView:(UIImageView*)senseImageView
           withWidthConstraint:(NSLayoutConstraint*)widthConstraint
           andHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    // using constraints rather than Affine transforms b/c bottom constraint
    // doesn't respect the transform
    CGFloat scale = HEMVoiceTutorialInitialSenseScale;
    CGFloat width = [widthConstraint constant] * scale;
    CGFloat height = [heightConstraint constant] * scale;
    
    [widthConstraint setConstant:width];
    [heightConstraint setConstant:height];
    
    [self setSenseImageView:senseImageView];
    [self setSenseWidthConstraint:widthConstraint];
    [self setSenseHeightConstraint:heightConstraint];
}

- (void)bindWithTableImageView:(UIImageView*)tableImageView
          withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [self setOrigTableBottomMargin:[bottomConstraint constant]];
    [self setTableImageView:tableImageView];
    [self setTableBottomConstraint:bottomConstraint];
}

- (void)bindWithLaterButton:(UIButton*)laterButton
       withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [laterButton addTarget:self
                    action:@selector(finish)
          forControlEvents:UIControlEventTouchUpInside];
    [laterButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[laterButton titleLabel] setFont:[UIFont buttonSmall]];
    [self setOrigLaterBottomMargin:[bottomConstraint constant]];
    [self setLaterButton:laterButton];
    [self setLaterButtonBottomConstraint:bottomConstraint];
}

- (void)bindWithContinueButton:(UIButton*)button {
    [button addTarget:self
               action:@selector(start)
     forControlEvents:UIControlEventTouchUpInside];
    [self setContinueButton:button];
}

#pragma mark - Presenter Events

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self animateSenseRings];
}

#pragma mark - Ring animation

- (CABasicAnimation*)fadeAnimationWithDelay:(CGFloat)delay
                                       from:(CGFloat)from
                                         to:(CGFloat)to {
    CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [fade setFromValue:@(from)];
    [fade setToValue:@(to)];
    [fade setBeginTime:delay];
    [fade setDuration:HEMVoiceTutorialRingAnimeDuration];
    [fade setFillMode:kCAFillModeForwards];
    return fade;
}

- (CAShapeLayer*)senseRingLayerWithSize:(CGFloat)size {
    
    CGPoint sensePosition = [[[self senseImageView] layer] position];
    CGRect ringFrame = CGRectZero;
    ringFrame.size = CGSizeMake(size, size);
    
    CAShapeLayer* ring = [CAShapeLayer layer];
    [ring setPath:[[UIBezierPath bezierPathWithOvalInRect:ringFrame] CGPath]];
    [ring setFrame:ringFrame];
    [ring setPosition:sensePosition];
    [ring setFillColor:[[UIColor grey4] CGColor]];
    [ring fillColor];
    [ring setOpacity:0.0f];
    
    return ring;
}

- (void)addAnimationTo:(CALayer*)ring
       withFadeInDelay:(CGFloat)fadeInDelay
          fadeOutDelay:(CGFloat)fadeOutDelay {
    [ring removeAllAnimations];
    
    CGFloat totalDuration = fadeOutDelay + HEMVoiceTutorialRingAnimeDuration;
    CGFloat fullAlpha = HEMVoiceTutorialInProgressRingAlpha;
    
    CABasicAnimation* fadeIn = [self fadeAnimationWithDelay:fadeInDelay
                                                       from:0.0f
                                                         to:fullAlpha];
    CABasicAnimation* fadeOut = [self fadeAnimationWithDelay:fadeInDelay
                                                        from:fullAlpha
                                                          to:0.0f];
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    [group setAnimations:@[fadeIn, fadeOut]];
    [group setRepeatCount:MAXFLOAT];
    [group setDuration:totalDuration];
    
    [ring addAnimation:group forKey:@"fade"];
}

- (void)animateSenseRings {
    if (![self outerSenseRing]
        && ![self middleSenseRing]
        && ![self innerSenseRing]) {
        UIView* ringContainer = [[self senseImageView] superview];
        CALayer* ringContainerLayer = [ringContainer layer];
        CALayer* senseLayer = [[self senseImageView] layer];
        
        CGFloat size = HEMVoiceTutorialInProgressOuterRingSize;
        CAShapeLayer* ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setOuterSenseRing:ring];
        
        size = HEMVoiceTutorialInProgressMiddleRingSize;
        ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setMiddleSenseRing:ring];
        
        size = HEMVoiceTutorialInProgressInnerRingSize;
        ring = [self senseRingLayerWithSize:size];
        [ringContainerLayer insertSublayer:ring below:senseLayer];
        [self setInnerSenseRing:ring];
    }
    
    CGFloat fadeInDelay = HEMVoiceTutorialRingAnimeDelay * 2;
    CGFloat fadeOutDelay = fadeInDelay;
    [self addAnimationTo:[self outerSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
    
    fadeInDelay = HEMVoiceTutorialRingAnimeDelay;
    [self addAnimationTo:[self middleSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
    
    fadeInDelay = 0.0f;
    [self addAnimationTo:[self innerSenseRing]
         withFadeInDelay:fadeInDelay
            fadeOutDelay:fadeOutDelay];
}

#pragma mark - Actions

- (void)voiceInfo {
    DDLogVerbose(@"show voice info");
    HEMActionSheetViewController *sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    
    // title view
    NSString* title = NSLocalizedString(@"onboarding.voice.info.title", nil);
    NSString* message = NSLocalizedString(@"onboarding.voice.info.message", nil);
    NSDictionary* messageAttributes = @{NSFontAttributeName : [UIFont body],
                                        NSForegroundColorAttributeName : [UIColor grey5]};
    NSMutableAttributedString* attrMessage = [[NSMutableAttributedString alloc] initWithString:message attributes:messageAttributes];
    HEMActionSheetTitleView* titleView = [[HEMActionSheetTitleView alloc] initWithTitle:title andDescription:attrMessage];
    
    [sheet setCustomTitleView:titleView];
    
    __weak typeof(self) weakSelf = self;
    NSString* cancelOption = NSLocalizedString(@"actions.close", nil);
    [sheet setOptionTextAlignment:NSTextAlignmentCenter];
    [sheet addDismissAction:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setInfoShowing:NO];
        [strongSelf listenForVoiceResult];
    }];
    [sheet addOptionWithTitle:cancelOption
                   titleColor:[UIColor tintColor]
                  description:nil
                    imageName:nil
                       action:^{
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           [strongSelf setInfoShowing:NO];
                           [strongSelf listenForVoiceResult];
                       }];
    
    [self stopListeningForVoiceResult];
    [self setInfoShowing:YES];
    [[self delegate] showController:sheet fromPresenter:self];
}

- (void)finish {
    [self stopListeningForVoiceResult];
    
    [[self innerSenseRing] removeAllAnimations];
    [[self middleSenseRing] removeAllAnimations];
    [[self outerSenseRing] removeAllAnimations];
    
    [[self delegate] didFinishTutorialFrom:self];
}

- (void)start {
    [[self navItem] setRightBarButtonItem:[self infoItem]];
    
    [[self speechCommandLabel] sizeToFit];
    [[self speechLabelContainer] setHidden:NO];
    [[self speechErrorLabel] setHidden:YES];
    [[self continueButton] setHidden:YES];
    [[self titleLabel] setHidden:YES];
    [[self descriptionLabel] setHidden:YES];
    [[self tryNowLabel] setHidden:NO];
    
    CGSize senseSize = [[self senseImageView] image].size;
    CGFloat laterBottom = HEMVoiceTutorialInProgressLaterBottomMargin;
    CGFloat voiceContentMinY = CGRectGetMinY([[self voiceContentContainer] frame]);
    CGFloat tryNowMaxY = CGRectGetMaxY([[self tryNowLabel] frame]);
    CGFloat adjustedContentCenter = [[self voiceContentCenterConstraint] constant];;
    CGFloat minVoiceContentTopMargin = HEMVoiceTutorialMinContentTopSpacing;
    
    if (HEMIsIPhone4Family()) {
        [[self navItem] setTitle:nil];
        [[self tableImageView] setHidden:YES];
        minVoiceContentTopMargin = HEMVoiceTutorialMinContentTopSpacing4s;
    }

    if (voiceContentMinY < tryNowMaxY + minVoiceContentTopMargin) {
        CGFloat currentCenter = [[self voiceContentCenterConstraint] constant];
        adjustedContentCenter = currentCenter + minVoiceContentTopMargin;
    }
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[self speechCommandBottomConstraint] setConstant:0];
        [[self senseWidthConstraint] setConstant:senseSize.width];
        [[self senseHeightConstraint] setConstant:senseSize.height];
        [[self laterButtonBottomConstraint] setConstant:laterBottom];
        [[self voiceContentCenterConstraint] setConstant:adjustedContentCenter];
        [[self tableBottomConstraint] setConstant:0.0f];
        [[self tableImageView] setAlpha:HEMVoiceTutorialInProgressTableAlpha];
        [[[self voiceContentContainer] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self animateSenseRings];
        [self listenForVoiceResult];
    }];
}

#pragma mark - Listen

- (void)stopListeningForVoiceResult {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HEMVoiceNotification object:[self voiceService]];
    [[self voiceService] stopListeningForVoiceResult];
}

- (void)listenForVoiceResult {
    if ([self isInfoShowing]) {
        [self stopListeningForVoiceResult];
        return;
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(didGetVoiceResult:)
                   name:HEMVoiceNotification
                 object:[self voiceService]];
    [[self voiceService] startListeningForVoiceResult];
}

- (void)didGetVoiceResult:(NSNotification*)note {
    if ([self isInfoShowing]) {
        return;
    }
    
    SENSpeechResult* result = [note userInfo][HEMVoiceNotificationInfoResult];
    if (result) {
        NSDictionary* props = @{kHEManaltyicsEventPropStatus : @([result status])};
        [SENAnalytics track:HEMAnalyticsEventVoiceResponse
                 properties:props
                 onboarding:[self onboarding]];
        
        switch ([result status]) {
            case SENSpeechStatusOk:
                [self showCorrectResponse];
                break;
            default: {
                NSString* message = NSLocalizedString(@"onboarding.voice.error.not-understood", nil);
                [self showUnrecognizedResponse:message];
                break;
            }
        }
        
    } else {
        NSError* error = [note userInfo][HEMVoiceNotificationInfoError];
        DDLogWarn(@"got voice result error %@", error);
        NSString* message = NSLocalizedString(@"onboarding.voice.error.problem", nil);
        [self showUnrecognizedResponse:message];
    }
}

#pragma mark - Sense colors

- (void)prepareSenseRingColor:(UIColor*)color {
    CGColorRef colorRef = [color CGColor];
    [[self innerSenseRing] setFillColor:colorRef];
    [[self middleSenseRing] setFillColor:colorRef];
    [[self outerSenseRing] setFillColor:colorRef];
}

- (void)updatesenseRingColor {
    [[self innerSenseRing] fillColor];
    [[self middleSenseRing] fillColor];
    [[self outerSenseRing] fillColor];
}

#pragma mark - Response Handling

- (void)restartListeningForResponse {
    CGFloat errorHeight = CGRectGetHeight([[self speechErrorLabel] bounds]);
    [[self speechErrorBottomConstraint] setConstant:-errorHeight];
    [[self speechCommandBottomConstraint] setConstant:0];
    
    [self prepareSenseRingColor:[UIColor grey4]];
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[self tryNowLabel] setAlpha:1.0f];
        [[self speechCommandLabel] setAlpha:1.0f];
        [[self speechErrorLabel] setAlpha:0.0f];
        [self updatesenseRingColor];
        [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoiceGray"]];
        [[[self speechCommandLabel] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[self speechErrorLabel] setHidden:YES];
        __strong typeof(self) weakSelf = self;
        int64_t delay = (int64_t)(HEMVoiceTutorialResponseDuration * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf failures] == HEMVoiceTutorialFailureBeforeTip) {
                [strongSelf voiceInfo];
            } else {
                [strongSelf listenForVoiceResult];
            }
        });
        
    }];
}

- (void)showUnrecognizedResponse:(NSString*)message {
    if (![self isVisible]) {
        return;
    }
    
    [self setFailures:[self failures] + 1];
    [self stopListeningForVoiceResult];
    
    [self prepareSenseRingColor:[UIColor red4]];
    
    [[self tryNowLabel] setAlpha:0.0f];
    [[self speechErrorLabel] setText:message];
    [[self speechErrorLabel] sizeToFit];
    [[self speechErrorLabel] setHidden:NO];
    [[self speechErrorLabel] setAlpha:0.0f];
    [[self speechErrorBottomConstraint] setConstant:0.0f];
    
    CGFloat commandHeight = CGRectGetHeight([[self speechCommandLabel] bounds]);
    [[self speechCommandBottomConstraint] setConstant:-commandHeight];
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[[self speechCommandLabel] superview] layoutIfNeeded];
        [[self speechErrorLabel] setAlpha:1.0f];
        [[self speechCommandLabel] setAlpha:0.0f];
        [self updatesenseRingColor];
        [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoiceRed"]];
    } completion:^(BOOL finished) {
        __weak typeof(self) weakSelf = self;
        int64_t delay = (int64_t)(HEMVoiceTutorialResponseDuration * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf restartListeningForResponse];
        });
    }];
}

- (void)showCorrectResponse {
    [self stopListeningForVoiceResult];
    
    [[self tryNowLabel] setAlpha:0.0f];
    [[self laterButton] setHidden:YES];
    [[self navItem] setRightBarButtonItem:nil];

    UIColor* successColor = [UIColor tintColor];
    [self prepareSenseRingColor:successColor];
    
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [self updatesenseRingColor];
        [[self speechCommandLabel] setTextColor:successColor];
        [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoiceBlue"]];
    } completion:^(BOOL finished) {
        __weak typeof(self) weakSelf = self;
        int64_t delay = (int64_t)(HEMVoiceTutorialResponseDuration * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf finish];
        });
    }];
    
}

#pragma mark - clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_voiceService) {
        [_voiceService stopListeningForVoiceResult];
    }
}

@end
