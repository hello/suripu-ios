//
//  HEMBeforeSleepViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMBeforeSleepViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "UIFont+HEMStyle.h"

static NSInteger const HEMBeforeSleepNumberOfScreens = 5;
static CGFloat const HEMBeforeSleepTextPadding = 20.0f;
static CGFloat const HEMBeforeSleepDescriptionMargin = 10.0f;
static NSString* const HEMBeforeSleepImageNameFormat = @"senseColors%ld.png";
static NSString* const HEMBeforeSleepTitleKeyFormat = @"onboarding.before-sleep.%ld.title";
static NSString* const HEMBeforeSleepDescKeyFormat = @"onboarding.before-sleep.%ld.description";

@interface HEMBeforeSleepViewController() <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *dots;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextImageView;

@property (assign, nonatomic) CGFloat origContinueButtonBottomConstant;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [self configureScrollView];
    [self configureInitialScreen];
    [self trackAnalyticsEvent:HEMAnalyticsEventSenseColors];
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
    CGFloat contentWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    
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
                                                        NSForegroundColorAttributeName : [HelloStyleKit onboardingDescriptionColor]}];
}


- (UIImage*)imageNameForScreen:(NSUInteger)screen {
    NSString* imageName = [NSString stringWithFormat:HEMBeforeSleepImageNameFormat, screen];
    return [UIImage imageNamed:imageName];
}

- (void)configureInitialScreen {
    [[self currentImageView] setImage:[self imageNameForScreen:1]];
    [[self nextImageView] setImage:[self imageNameForScreen:2]];
    [[self nextImageView] setAlpha:0.0f];
    [[self dots] setNumberOfPages:HEMBeforeSleepNumberOfScreens];
    [[self dots] setCurrentPageIndicatorTintColor:[HelloStyleKit senseBlueColor]];
    [[self dots] setPageIndicatorTintColor:[HelloStyleKit pageControlTintColor]];
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
    [label setTextColor:[HelloStyleKit onboardingTitleColor]];
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
        [self swapToNextImageForPage:nextPage withPercentage:percentage];
    } else {
        [self swapToPreviousImageForPage:nextPage withPercentage:percentage];
    }
    
    if (nextPage >= HEMBeforeSleepNumberOfScreens - 2 && nextPage < HEMBeforeSleepNumberOfScreens - 1) {
        [self moveContinueButtonWithPercentage:percentage];
    }
    
}

#pragma mark -

- (void)advanceToPage:(NSInteger)currentPage {
    UIImageView* tempView = [self nextImageView];
    [self setNextImageView:[self currentImageView]];
    [self setCurrentImageView:tempView];
    [[self dots] setCurrentPage:currentPage];
}

- (void)swapToNextImageForPage:(CGFloat)nextPage withPercentage:(CGFloat)percentage {
    UIImage* nextImage = [self imageNameForScreen:MIN(HEMBeforeSleepNumberOfScreens, ceilf(nextPage) + 1)];
    if (![[[self nextImageView] image] isEqual:nextImage]) {
        [[self nextImageView] setImage:nextImage];
    }
    [[self currentImageView] setAlpha:1-percentage];
    [[self nextImageView] setAlpha:percentage];
}

- (void)swapToPreviousImageForPage:(CGFloat)previousPage withPercentage:(CGFloat)percentage {
    UIImage* nextImage = [self imageNameForScreen:MAX(1, floorf(previousPage) + 1)];
    if (![[[self nextImageView] image] isEqual:nextImage]) {
        [[self nextImageView] setImage:nextImage];
    }
    [[self currentImageView] setAlpha:percentage];
    [[self nextImageView] setAlpha:1-percentage];
}

- (void)moveContinueButtonWithPercentage:(CGFloat)percentage {
    CGFloat height = CGRectGetHeight([[self continueButton] bounds]);
    CGFloat totalDiff = fabsf([self origContinueButtonBottomConstant]) + height;
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
        if ([sensor condition] == SENSensorConditionUnknown) {
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)next:(id)sender {
    NSString* nextSegueId
        = [self sensorsAreReady]
        ? [HEMOnboardingStoryboard beforeSleeptoRoomCheckSegueIdentifier]
        : [HEMOnboardingStoryboard beforeSleepToSmartAlarmSegueIdentifier];
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

@end
