//
//  HEMBeforeSleepViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMBeforeSleepViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "UIColor+HEMStyle.h"
#import "HEMOnboardingStoryboard.h"
#import "UIFont+HEMStyle.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMScreenUtils.h"

static NSInteger const HEMBeforeSleepNumberOfScreens = 5;
static CGFloat const HEMBeforeSleepSideImageInitialScale = 0.65f;
static CGFloat const HEMBeforeSleepTextPadding = 20.0f;
static CGFloat const HEMBeforeSleepDescriptionMargin = 10.0f;
static CGFloat const HEMBeforeSleepVideoAlphaPlayThreshold = 0.9f;
static NSString* const HEMBeforeSleepTitleKeyFormat = @"onboarding.before-sleep.%ld.title";
static NSString* const HEMBeforeSleepDescKeyFormat = @"onboarding.before-sleep.%ld.description";

typedef NS_ENUM(NSUInteger, HEMBeforeSleepScreen) {
    HEMBeforeSleepScreenInitial = 0,
    HEMBeforeSleepScreenIdeal = 1,
    HEMBeforeSleepScreenWarning = 2,
    HEMBeforeSleepScreenAlert = 3,
    HEMBeforeSleepScreenVideo = 4
};

@interface HEMBeforeSleepViewController() <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *dots;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet HEMEmbeddedVideoView* videoView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *initialRightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *initialLeftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextLeadingToCenterConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *prevTrailingToCenterConstraint;

@property (assign, nonatomic) CGFloat origContinueButtonBottomConstant;
@property (assign, nonatomic) CGFloat origNextLeadingConstant;
@property (assign, nonatomic) CGFloat origPrevTrailingConstant;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVideoView];
    [self configureButtons];
    [self configureScrollView];
    [self configureInitialScreen];
    [self trackAnalyticsEvent:HEMAnalyticsEventSenseColors];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self canPlayVideo]) {
        [[self videoView] playVideoWhenReady];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[self videoView] pause];
}

- (BOOL)canPlayVideo {
    return [[self videoView] alpha] > HEMBeforeSleepVideoAlphaPlayThreshold
        && [[self videoView] isReady];
}

- (void)configureVideoView {
    UIImage* image = [UIImage imageNamed:@"bedroom_condition"];
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.bedroom-condition", nil);

    [[self videoView] setFirstFrame:image videoPath:videoPath];
    [[self videoView] setAlpha:0.0f];
}

- (void)configureButtons {
    [self enableBackButton:NO];
    
    // hide the continue button initially
    [self setOrigContinueButtonBottomConstant:[[self continueButtonBottomConstraint] constant]];
    CGFloat buttonHeight = CGRectGetHeight([[self continueButton] bounds]);
    [[self continueButtonBottomConstraint] setConstant:-buttonHeight];
}

- (void)configureScrollView {
    CGFloat x = HEMBeforeSleepTextPadding;
    CGFloat contentWidth = CGRectGetWidth(HEMKeyWindowBounds());
    
    CGFloat maxLabelWidth = contentWidth - (2 * x);
    NSString* titleKey = nil;
    NSString* descriptionKey = nil;
    CGFloat subtitleY = 0.0f;
    
    for (int i = 0; i < HEMBeforeSleepNumberOfScreens; i++) {
        NSInteger screenNumber = i+1;
        titleKey = [NSString stringWithFormat:HEMBeforeSleepTitleKeyFormat, screenNumber];
        subtitleY = [self addTitleLabelWithText:NSLocalizedString(titleKey, nil)
                                             to:[self contentScrollView]
                                            atX:x
                                   withMaxWidth:maxLabelWidth];
        
        descriptionKey = [NSString stringWithFormat:HEMBeforeSleepDescKeyFormat, screenNumber];
        [self addDescriptionLabelWithText:[self attributedDescriptionWithKey:descriptionKey]
                                       to:[self contentScrollView]
                                 atOrigin:CGPointMake(x, subtitleY + HEMBeforeSleepDescriptionMargin)
                             withMaxWidth:maxLabelWidth];
        
        x += contentWidth;
    }
    
    CGSize contentSize = [[self contentScrollView] contentSize];
    contentSize.width = HEMBeforeSleepNumberOfScreens * contentWidth;
    [[self contentScrollView] setContentSize:contentSize];
    
    [[self contentScrollView] setClipsToBounds:YES];
}

- (NSAttributedString*)attributedDescriptionWithKey:(NSString*)localizedKey {
    NSString* description = NSLocalizedString(localizedKey, nil);
    return [[NSAttributedString alloc] initWithString:description
                                           attributes:@{NSFontAttributeName : [UIFont onboardingDescriptionFont],
                                                        NSForegroundColorAttributeName : [UIColor grey5]}];
}


- (UIImage*)centerImageForPageIndex:(NSUInteger)index {
    switch (index) {
        case HEMBeforeSleepScreenInitial:
        case HEMBeforeSleepScreenIdeal:
            return [UIImage imageNamed:@"senseGreen"];
        case HEMBeforeSleepScreenWarning:
            return [UIImage imageNamed:@"senseYellow"];
        case HEMBeforeSleepScreenAlert:
            return [UIImage imageNamed:@"senseRed"];
        default:
            return nil;
    }
}

- (void)configureInitialScreen {
    [[self initialRightImageView] setImage:[self centerImageForPageIndex:HEMBeforeSleepScreenAlert]];
    [[self centerImageView] setImage:[self centerImageForPageIndex:HEMBeforeSleepScreenIdeal]];
    [[self initialLeftImageView] setImage:[self centerImageForPageIndex:HEMBeforeSleepScreenWarning]];
    
    CGFloat initialScale = HEMBeforeSleepSideImageInitialScale;
    CGAffineTransform xform = CGAffineTransformMakeScale(initialScale, initialScale);
    [[self initialRightImageView] setTransform:xform];
    [[self initialLeftImageView] setTransform:xform];
    
    [self setOrigNextLeadingConstant:[[self nextLeadingToCenterConstraint] constant]];
    [self setOrigPrevTrailingConstant:[[self prevTrailingToCenterConstraint] constant]];

    [[self dots] setNumberOfPages:HEMBeforeSleepNumberOfScreens];
    [[self dots] setCurrentPageIndicatorTintColor:[UIColor tintColor]];
    [[self dots] setPageIndicatorTintColor:[UIColor grey2]];
    [[self dots] setUserInteractionEnabled:NO];
    [[self dots] setCurrentPage:0];
}

- (CGFloat)addTitleLabelWithText:(NSString*)text
                              to:(UIScrollView*)scrollView
                             atX:(CGFloat)x
                    withMaxWidth:(CGFloat)maxWidth {
    
    UILabel* label = [[UILabel alloc] init];
    [label setBackgroundColor:[scrollView backgroundColor]];
    [label setText:text];
    [label setFont:[UIFont onboardingTitleFont]];
    [label setTextColor:[UIColor grey7]];
    [label setNumberOfLines:0];
    
    CGRect labelFrame = [self frameForLabel:label withMaxWidth:maxWidth];
    labelFrame.origin.x = x;
    [label setFrame:labelFrame];
    
    [scrollView addSubview:label];
    
    return CGRectGetMaxY([label frame]);
}

- (void)addDescriptionLabelWithText:(NSAttributedString*)text
                                 to:(UIScrollView*)scrollView
                                atOrigin:(CGPoint)origin
                       withMaxWidth:(CGFloat)maxWidth {
    
    UILabel* label = [[UILabel alloc] init];
    [label setBackgroundColor:[scrollView backgroundColor]];
    [label setAttributedText:text];
    [label setNumberOfLines:0];
    
    CGRect labelFrame = [self frameForLabel:label withMaxWidth:maxWidth];
    labelFrame.origin = origin;
    [label setFrame:labelFrame];
    
    [scrollView addSubview:label];
}

- (CGRect)frameForLabel:(UILabel*)label withMaxWidth:(CGFloat)maxWidth {
    CGSize constraint = CGSizeMake(maxWidth, MAXFLOAT);
    CGSize textSize = [label sizeThatFits:constraint];
    
    CGRect labelFrame = CGRectZero;
    labelFrame.size.width = maxWidth;
    labelFrame.size.height = textSize.height;
    
    return labelFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat fullWidth = CGRectGetWidth([scrollView bounds]);
    NSInteger remainder = (NSInteger)[scrollView contentOffset].x % (NSInteger)fullWidth;
    CGFloat percentage = MAX(0.0f, remainder / fullWidth);
    CGFloat nextPage = [scrollView contentOffset].x / fullWidth; // nextPage is an index
    CGFloat prevContentOffset = [[self dots] currentPage] * fullWidth;

    if ([scrollView contentOffset].x >= prevContentOffset + fullWidth
        || [scrollView contentOffset].x <= prevContentOffset - fullWidth) {
        [self advanceToPage:nextPage];
    } else if ([scrollView contentOffset].x > prevContentOffset) {
        [self swapToNextIllustrationForPage:nextPage withPercentage:percentage];
    } else {
        [self swapToPreviousIllustrationForPage:nextPage withPercentage:percentage];
    }
    
    if (nextPage >= HEMBeforeSleepNumberOfScreens - 2 && nextPage < HEMBeforeSleepNumberOfScreens - 1) {
        [self moveContinueButtonWithPercentage:percentage];
    }
    
}

#pragma mark -

- (void)updateInitialSideImageStateWithPercentage:(CGFloat)percentage {
    [[self initialRightImageView] setAlpha:1.0f];
    [[self initialLeftImageView] setAlpha:1.0f];
    [[self centerImageView] setImage:[self centerImageForPageIndex:HEMBeforeSleepScreenIdeal]];
    
    CGFloat prevImageWidth = CGRectGetWidth([[self initialRightImageView] bounds]);
    CGFloat fullyHiddenPrevConstant = -prevImageWidth / 2.0f;
    CGFloat nextConstant = [self origPrevTrailingConstant] - (fullyHiddenPrevConstant * percentage);
    [[self prevTrailingToCenterConstraint] setConstant:nextConstant];
    
    CGFloat nextImageWidth = CGRectGetWidth([[self initialLeftImageView] bounds]);
    CGFloat fullyHiddenNextConstant = -nextImageWidth / 2.0f;
    nextConstant = [self origNextLeadingConstant] + (fullyHiddenNextConstant * percentage);
    [[self nextLeadingToCenterConstraint] setConstant:nextConstant];
}

- (void)advanceToPage:(NSInteger)currentPageIndex {
    switch (currentPageIndex) {
        case HEMBeforeSleepScreenVideo:
        case HEMBeforeSleepScreenIdeal:
        case HEMBeforeSleepScreenWarning:
        case HEMBeforeSleepScreenAlert: {
            if ([[self centerImageView] alpha] != 1.0f) {
                UIImageView* tempView = [self tempImageView];
                [self setTempImageView:[self centerImageView]];
                [self setCenterImageView:tempView];
            }
            break;
        }
        case HEMBeforeSleepScreenInitial:
        default:
            break;
    }
    [[self dots] setCurrentPage:currentPageIndex];
}

- (void)swapToNextIllustrationForPage:(CGFloat)nextPage withPercentage:(CGFloat)percentage {
    NSInteger nextPageIndex = ceilf(nextPage);

    switch (nextPageIndex) {
        case HEMBeforeSleepScreenIdeal: {
            [self updateInitialSideImageStateWithPercentage:percentage];
            break;
        }
        case HEMBeforeSleepScreenVideo:
            [self prepareVideoWithVisibilityPercentage:percentage];
            [[self centerImageView] setAlpha:1-percentage];
            break;
        case HEMBeforeSleepScreenWarning:
        case HEMBeforeSleepScreenAlert: {
            UIImage* nextImage = [self centerImageForPageIndex:MIN(HEMBeforeSleepScreenVideo,
                                                                   nextPageIndex)];
            
            [self crossFadeCenterImageWithAlpha:1 - percentage
                                 tempImageAlpha:percentage
                                      nextImage:nextImage];
            break;
        }
        case HEMBeforeSleepScreenInitial:
        default:
            break;
    }
    
}

- (void)swapToPreviousIllustrationForPage:(CGFloat)previousPage withPercentage:(CGFloat)percentage {
    NSInteger prevPageIndex = floorf(previousPage);
    
    switch (prevPageIndex + 1) {
        case HEMBeforeSleepScreenIdeal: {
            [self updateInitialSideImageStateWithPercentage:percentage];
            break;
        }
        case HEMBeforeSleepScreenVideo:
            [self prepareVideoWithVisibilityPercentage:percentage];
            [[self tempImageView] setAlpha:1 - percentage];
            break;
        case HEMBeforeSleepScreenWarning:
        case HEMBeforeSleepScreenAlert: {
            UIImage* nextImage = [self centerImageForPageIndex:MAX(0, prevPageIndex)];
            [self crossFadeCenterImageWithAlpha:percentage
                                 tempImageAlpha:1 - percentage
                                      nextImage:nextImage];
            break;
        }
        case HEMBeforeSleepScreenInitial:
        default:
            break;
    }
}

- (void)crossFadeCenterImageWithAlpha:(CGFloat)centerAlpha
                       tempImageAlpha:(CGFloat)tempAlpha
                            nextImage:(UIImage*)nextImage {
    
    [[self initialRightImageView] setAlpha:0.0f];
    [[self initialLeftImageView] setAlpha:0.0f];

    if (![[[self tempImageView] image] isEqual:nextImage]) {
        [[self tempImageView] setImage:nextImage];
    }
    
    [[self centerImageView] setAlpha:centerAlpha];
    [[self tempImageView] setAlpha:tempAlpha];
    
}

- (void)prepareVideoWithVisibilityPercentage:(CGFloat)percentage {
    if (percentage > HEMBeforeSleepVideoAlphaPlayThreshold) {
        if (![[self videoView] isReady]) {
            [[self videoView] setReady:YES];
        } else {
            [[self videoView] playVideoWhenReady];
        }
    } else if (percentage > 0.0f) {
        [[self videoView] pause];
    } else {
        [[self videoView] stop];
    }
    
    [[self videoView] setAlpha:percentage];
}

- (void)moveContinueButtonWithPercentage:(CGFloat)percentage {
    CGFloat height = CGRectGetHeight([[self continueButton] bounds]);
    CGFloat totalDiff = fabs([self origContinueButtonBottomConstant]) + height;
    CGFloat movement = totalDiff * percentage;
    [[self continueButtonBottomConstraint] setConstant:-height + movement];
    [[self view] layoutIfNeeded];
}

#pragma mark - Navigation

- (BOOL)sensorsAreReady {
    NSArray* sensors = [SENSensor sensors];
    if ([sensors count] == 0) {
        return NO;
    }
    
    for (SENSensor* sensor in sensors) {
        if ([sensor condition] == SENConditionUnknown) {
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)next:(id)sender {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service saveOnboardingCheckpoint:HEMOnboardingCheckpointSenseColorsFinished];
    
    NSString* nextSegueId
        = [self sensorsAreReady]
        ? [HEMOnboardingStoryboard beforeSleeptoRoomCheckSegueIdentifier]
        : [HEMOnboardingStoryboard beforeSleepToSmartAlarmSegueIdentifier];
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

@end
