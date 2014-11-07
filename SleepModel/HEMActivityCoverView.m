//
//  HEMActivityCoverView.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActivityCoverView.h"
#import "HelloStyleKit.h"

static CGFloat kHEMActivityMargins = 30.0f;
static CGFloat kHEMActivityViewSeparation = 20.0f;
static CGFloat kHEMActivityAnimDuration = 0.5f;
static CGFloat kHEMActivityResultDisplayTime = 1.5f;

@interface HEMActivityCoverView()

@property (nonatomic, strong) UILabel* activityLabel;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@property (nonatomic, assign, getter=isShowing) BOOL showing;

@end

@implementation HEMActivityCoverView

- (id)init {
    UIScreen* mainScreen = [UIScreen mainScreen];
    return [self initWithFrame:[mainScreen bounds]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self addLabel];
    [self addActivityIndicator];
}

- (void)addLabel {
    [self setActivityLabel:[[UILabel alloc] init]];
    [[self activityLabel] setFont:[UIFont fontWithName:@"Calibre-Light" size:26.0f]];
    [[self activityLabel] setTextColor:[HelloStyleKit onboardingGrayColor]];
    [[self activityLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self activityLabel] setNumberOfLines:0];
    
    [self addSubview:[self activityLabel]];
}

- (void)addActivityIndicator {
    [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[self activityView] setHidesWhenStopped:YES];
    [self addSubview:[self activityView]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    
    CGSize constraint = CGSizeZero;
    constraint.width = bWidth - (2*kHEMActivityMargins);
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self activityLabel] sizeThatFits:constraint];
    
    CGRect activityFrame = [[self activityView] frame];
    
    CGRect labelFrame = [[self activityLabel] frame];
    labelFrame.size.width = constraint.width;
    labelFrame.size.height = textSize.height;
    labelFrame.origin.y = (bHeight -
                           (textSize.height
                            + kHEMActivityViewSeparation
                            + CGRectGetHeight(activityFrame))) / 2;
    labelFrame.origin.x = kHEMActivityMargins;
    [[self activityLabel] setFrame:labelFrame];
    
    activityFrame.origin.y = CGRectGetMaxY(labelFrame) + kHEMActivityViewSeparation;
    activityFrame.origin.x = (bWidth - CGRectGetWidth(activityFrame))/2;
    [[self activityView] setFrame:activityFrame];
}

- (void)updateText:(NSString*)text completion:(void(^)(BOOL finished))completion {
    if (text == nil) {
        if (completion) completion (YES);
        return;
    }
    [UIView animateWithDuration:kHEMActivityAnimDuration
                     animations:^{
                         [[self activityLabel] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self activityLabel] setText:text];
                         [self setNeedsLayout];
                         [UIView animateWithDuration:kHEMActivityAnimDuration
                                          animations:^{
                                              [[self activityLabel] setAlpha:1.0f];
                                          } completion:completion];
                     }];
}

#pragma mark - Public Interfaces

- (void)showInView:(UIView*)view completion:(void(^)(void))completion {
    [self showInView:view activity:YES completion:completion];
}

- (void)showInView:(UIView*)view
          withText:(NSString*)text
          activity:(BOOL)activity
        completion:(void(^)(void))completion {
    
    [[self activityLabel] setText:text];
    [[self activityLabel] setAlpha:1.0f];
    [self showInView:view activity:activity completion:completion];
}

- (void)showInView:(UIView*)view activity:(BOOL)activity completion:(void(^)(void))completion {
    [self setFrame:[view bounds]];
    [self setNeedsLayout];
    [self setAlpha:0.0f];
    [[self activityView] stopAnimating]; // in case it's animating
    [view addSubview:self];
    
    [UIView animateWithDuration:kHEMActivityAnimDuration
                     animations:^{
                         [self setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         if (activity) {
                             [[self activityView] startAnimating];
                         }
                         [self setShowing:YES];
                         if (completion) completion ();
                     }];
}

- (void)dismissWithResultText:(NSString*)text
                   completion:(void(^)(void))completion {
    
    [[self activityView] stopAnimating];
    [self updateText:text completion:^(BOOL finished) {
        [UIView animateWithDuration:kHEMActivityAnimDuration
                              delay:kHEMActivityResultDisplayTime
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [[self activityLabel] setText:nil];
                             [self removeFromSuperview];
                             [self setShowing:NO];
                             if (completion) completion();
                         }];
    }];
    
}

@end
