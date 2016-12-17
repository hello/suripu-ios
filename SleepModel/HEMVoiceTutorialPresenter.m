//
//  HEMVoiceTutorialPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSpeechResult.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMVoiceTutorialPresenter.h"
#import "HEMScreenUtils.h"
#import "HEMVoiceService.h"
#import "HEMActionSheetViewController.h"
#import "HEMActionSheetTitleView.h"
#import "HEMAlertViewController.h"
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
static CGFloat const HEMVoiceTutorialTriggerDisplayDelay = 0.75f;
static CGFloat const HEMVoiceTutorialResponseDuration = 2.0f;
static CGFloat const HEMVoiceTutorialListenDelay = 1.0f;
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
@property (nonatomic, assign, getter=isRestarting) BOOL restarting;
@property (nonatomic, assign, getter=hasShownInfo) BOOL infoShown;

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
                    action:@selector(later)
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

- (void)didAppear {
    [super didAppear];
    DDLogVerbose(@"voice tutorial did appear");
    if ([[self continueButton] isHidden]) { // tutorial started
        [self restartListeningForResponse];
    }
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
    [ring setFillColor:[[UIColor purple4] CGColor]];
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

- (void)stopSenseRingAnimation {
    [[self innerSenseRing] removeAllAnimations];
    [[self middleSenseRing] removeAllAnimations];
    [[self outerSenseRing] removeAllAnimations];
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
        [strongSelf restartListeningForResponse];
    }];
    [sheet addOptionWithTitle:cancelOption
                   titleColor:[UIColor tintColor]
                  description:nil
                    imageName:nil
                       action:^{
                           __strong typeof(weakSelf) strongSelf = weakSelf;
                           [strongSelf setInfoShowing:NO];
                           [strongSelf restartListeningForResponse];
                       }];
    
    [self stopListeningForVoiceResult];
    [self setInfoShowing:YES];
    [self setInfoShown:YES];
    [[self delegate] showController:sheet fromPresenter:self];
}

- (void)later {
    [SENAnalytics track:HEMAnalyticsEventVoiceTutorialSkip];
    [self finish];
}

- (void)finish {
    [self stopListeningForVoiceResult];
    [self stopSenseRingAnimation];
    [[self delegate] didFinishTutorialFrom:self];
}

- (void)start {
    NSString* command = nil;
    NSMutableAttributedString* phrase = nil;

    [self prepareForStart:&phrase command:&command];
    
    // get sizing details
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
    
    __weak typeof(self) weakSelf = self;
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
        int64_t delayInSecs = (int64_t)(HEMVoiceTutorialTriggerDisplayDelay * NSEC_PER_SEC);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showSenseInWaitingState];
            // show by removing the camouflage
            [strongSelf showSampleVoiceCommand:command phrase:phrase];
            [strongSelf listenOrShowInfoWithDelay:nil];
        });
    }];
}

- (void)prepareForStart:(NSMutableAttributedString**)phrase command:(NSString**)command {
    [[self navItem] setRightBarButtonItem:[self infoItem]];
    
    [self resetSpeechCommand:phrase command:command];
    [[self speechCommandLabel] sizeToFit]; // to adjust constraints
    [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoiceGray"]];
    [[self speechLabelContainer] setHidden:NO];
    [[self speechErrorLabel] setHidden:YES];
    [[self continueButton] setHidden:YES];
    [[self titleLabel] setHidden:YES];
    [[self descriptionLabel] setHidden:YES];
    [[self tryNowLabel] setHidden:NO];
}

- (void)showSenseInWaitingState {
    [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoicePurple"]];
    [self animateSenseRings];
}

- (void)showSampleVoiceCommand:(NSString*)command phrase:(NSMutableAttributedString*)phrase {
    UIColor* textColor = [[self speechCommandLabel] textColor];
    if (textColor) {
        NSRange commandRange = [[phrase string] rangeOfString:command];
        [phrase setAttributes:@{NSForegroundColorAttributeName : textColor} range:commandRange];
        [[self speechCommandLabel] setAttributedText:phrase];
    }
}

- (void)resetSpeechCommand:(NSMutableAttributedString**)phrase command:(NSString**)command {
    UIColor* baseColor = [[self speechCommandLabel] textColor];
    UIFont* baseFont = [[self speechCommandLabel] font];
    NSString* triggerPhraseFormat = NSLocalizedString(@"voice.tutorial.trigger.phrase.format", nil);
    NSString* phraseCommand = NSLocalizedString(@"voice.tutorial.command", nil);
    // hide the command by camouflage
    NSDictionary* commandProperties = @{NSFontAttributeName : baseFont,
                                        NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString* attributedCommand = [[NSAttributedString alloc] initWithString:phraseCommand
                                                                            attributes:commandProperties];
    NSMutableAttributedString* attributedPhrase =
    [[NSMutableAttributedString alloc] initWithFormat:triggerPhraseFormat
                                                 args:@[attributedCommand]
                                            baseColor:baseColor
                                             baseFont:baseFont];
    
    [[self speechCommandLabel] setAttributedText:attributedPhrase];
    
    *phrase = attributedPhrase;
    *command = phraseCommand;
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
    NSError* error = [note userInfo][HEMVoiceNotificationInfoError];
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
        
    } else if ([[error domain] isEqualToString:NSURLErrorDomain]
               && [error code] == NSURLErrorNotConnectedToInternet) {
        [self showNetworkError];
    } else {
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
    if ([self isRestarting]) {
        return;
    }
    [self setRestarting:YES];
    
    CGFloat errorHeight = CGRectGetHeight([[self speechErrorLabel] bounds]);
    [[self speechErrorBottomConstraint] setConstant:-errorHeight];
    [[self speechCommandBottomConstraint] setConstant:0];
    
    NSString* command = nil;
    NSMutableAttributedString* phrase = nil;
    [self resetSpeechCommand:&phrase command:&command];
    
    [self stopSenseRingAnimation];
    [self prepareSenseRingColor:[UIColor purple4]];
    [[self senseImageView] setImage:[UIImage imageNamed:@"senseVoiceGray"]];
    
    __strong typeof(self) weakSelf = self;
    [UIView animateWithDuration:HEMVoiceTutorialAnimeDuration animations:^{
        [[self tryNowLabel] setAlpha:1.0f];
        [[self speechCommandLabel] setAlpha:1.0f];
        [[self speechErrorLabel] setAlpha:0.0f];
        [self updatesenseRingColor];
        [[[self speechCommandLabel] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[self speechErrorLabel] setHidden:YES];
        
        int64_t delayInSecs = (int64_t)(HEMVoiceTutorialTriggerDisplayDelay * NSEC_PER_SEC);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showSenseInWaitingState];
            [strongSelf showSampleVoiceCommand:command phrase:phrase];
            [strongSelf listenOrShowInfoWithDelay:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf setRestarting:NO];
            }];
        });
        
    }];
}

- (void)listenOrShowInfoWithDelay:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    int64_t delayInSecs = (int64_t)(HEMVoiceTutorialListenDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf failures] == HEMVoiceTutorialFailureBeforeTip
            && ![strongSelf hasShownInfo]) {
            [strongSelf voiceInfo];
        } else {
            [strongSelf listenForVoiceResult];
        }
        if (completion) {
            completion ();
        }
    });
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

- (void)showNetworkError {
    [self stopListeningForVoiceResult];
    
    __weak typeof(self) weakSelf = self;
    NSString* title = NSLocalizedString(@"voice.tutorial.error.network.title", nil);
    NSString* message = NSLocalizedString(@"voice.tutorial.error.network.message", nil);
    HEMAlertViewController* dialogVC = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:^{
                              __strong typeof(weakSelf) strongSelf = weakSelf;
                              [strongSelf restartListeningForResponse];
                          }];
    
    [[self errorDelegate] showCustomerAlert:dialogVC fromPresenter:self];
}

#pragma mark - clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_voiceService) {
        [_voiceService stopListeningForVoiceResult];
    }
}

@end
