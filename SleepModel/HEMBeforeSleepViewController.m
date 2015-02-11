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
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "UIFont+HEMStyle.h"

static NSInteger const HEMBeforeSleepNumberOfScreens = 5;
static CGFloat const HEMBeforeSleepTextPadding = 20.0f;

@interface HEMBeforeSleepViewController() <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *dots;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueButtonBottomConstraint;

@property (assign, nonatomic) CGFloat origContinueButtonBottomConstant;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [self configureScrollView];
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseColors];
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
    NSString* titleKeyFormat = @"onboarding.before-sleep.%ld.title";
    NSString* titleKey = nil;
    
    for (int i = 0; i < HEMBeforeSleepNumberOfScreens; i++) {
        titleKey = [NSString stringWithFormat:titleKeyFormat, i+1];
        [self addTitleLabelWithText:NSLocalizedString(titleKey, nil)
                                 to:[self contentScrollView]
                                atX:x];
        x += contentWidth;
    }
    
    CGSize contentSize = [[self contentScrollView] contentSize];
    contentSize.width = x;
    [[self contentScrollView] setContentSize:contentSize];
    [[self dots] setNumberOfPages:HEMBeforeSleepNumberOfScreens];
    [[self dots] setCurrentPageIndicatorTintColor:[HelloStyleKit senseBlueColor]];
    [[self dots] setCurrentPage:0];
}

- (void)addTitleLabelWithText:(NSString*)text to:(UIScrollView*)scrollView atX:(CGFloat)x {
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = x;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setBackgroundColor:[scrollView backgroundColor]];
    [label setText:text];
    [label setFont:[UIFont onboardingTitleFont]];
    [label setTextColor:[HelloStyleKit onboardingTitleColor]];
    [label sizeToFit];
    
    [scrollView addSubview:label];
}

- (void)addSubtitleLabelWithText:(NSAttributedString*)text
                              to:(UIScrollView*)scrollView
                             atX:(CGFloat)x {
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger screenNumber = [scrollView contentOffset].x / CGRectGetWidth([scrollView bounds]);
    [[self dots] setCurrentPage:screenNumber];
}

#pragma mark - Navigation

- (IBAction)next:(id)sender {
    NSString* nextSegueId = [HEMOnboardingStoryboard beforeSleeptoRoomCheckSegueIdentifier];
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

@end
