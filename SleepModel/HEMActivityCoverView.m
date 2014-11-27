//
//  HEMActivityCoverView.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMActivityCoverView.h"
#import "HelloStyleKit.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAnimationUtils.h"

static CGFloat kHEMActivityMargins = 30.0f;
static CGFloat kHEMActivityViewSeparation = 20.0f;
static CGFloat kHEMActivityAnimDuration = 0.5f;
static CGFloat kHEMActivityResultDisplayTime = 2.0f;

@interface HEMActivityCoverView()

@property (nonatomic, strong) UILabel* activityLabel;
@property (nonatomic, strong) UIImageView* successMarkView;
@property (nonatomic, strong) HEMActivityIndicatorView* indicator;
@property (nonatomic, assign, getter=isShowing) BOOL showing;

@end

@implementation HEMActivityCoverView

- (id)init {
    UIScreen* mainScreen = [UIScreen mainScreen];
    return [self initWithFrame:[mainScreen bounds]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
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
    [self addActivityIndicator];
    [self addLabel];
}

- (void)addLabel {
    [self setActivityLabel:[[UILabel alloc] init]];
    [[self activityLabel] setFont:[UIFont onboardingActivityFontLarge]];
    [[self activityLabel] setTextColor:[HelloStyleKit onboardingGrayColor]];
    [[self activityLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self activityLabel] setNumberOfLines:0];
    
    [self addSubview:[self activityLabel]];
}

- (void)addActivityIndicator {
    UIImage* checkImage = [HelloStyleKit check];
    CGRect indicatorFrame = CGRectZero;
    indicatorFrame.size = checkImage.size;
    
    [self setIndicator:[[HEMActivityIndicatorView alloc] initWithFrame:indicatorFrame]];
    [self addSubview:[self indicator]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat bHeight = CGRectGetHeight([self bounds]);
    
    CGRect activityFrame = [[self indicator] frame];
    
    CGSize constraint = CGSizeZero;
    constraint.width = bWidth - (2*kHEMActivityMargins);
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self activityLabel] sizeThatFits:constraint];
    
    activityFrame.origin.y = (bHeight -
                              (textSize.height
                               + kHEMActivityViewSeparation
                               + CGRectGetHeight(activityFrame))) / 2;
    activityFrame.origin.x = (bWidth - CGRectGetWidth(activityFrame))/2;
    [[self indicator] setFrame:activityFrame];
    [[self successMarkView] setFrame:activityFrame]; // same as indicator
    
    CGRect labelFrame = [[self activityLabel] frame];
    labelFrame.size.width = constraint.width;
    labelFrame.size.height = textSize.height;
    labelFrame.origin.y = CGRectGetMaxY(activityFrame) + kHEMActivityViewSeparation;
    labelFrame.origin.x = kHEMActivityMargins;
    [[self activityLabel] setFrame:labelFrame];
}

- (UIView*)successMarkView {
    if (_successMarkView == nil) {
        UIImageView* mark = [[UIImageView alloc] initWithFrame:[[self indicator] frame]];
        [mark setImage:[HelloStyleKit check]];
        [mark setContentMode:UIViewContentModeScaleAspectFit];
        _successMarkView = mark;
    }
    return _successMarkView;
}

- (void)showSuccessMarkAnimated:(BOOL)animate completion:(void(^)(BOOL finished))completion {
    UIView* mark = [self successMarkView];
    
    if (animate) {
        [mark setTransform:CGAffineTransformMakeScale(0.0f, 0.0f)];
        [self addSubview:mark];
        [HEMAnimationUtils grow:mark completion:completion];
    } else {
        [self addSubview:mark];
        if (completion) completion (YES);
    }
    
}

#pragma mark - Updating Text

- (void)updateText:(NSString*)text completion:(void(^)(BOOL finished))completion {
    [self updateText:text hideActivity:NO completion:nil];
}

- (void)updateText:(NSString *)text hideActivity:(BOOL)hideActivity completion:(void (^)(BOOL))completion {
    if (text == nil) {
        if (completion) completion (YES);
        return;
    }
    [UIView animateWithDuration:kHEMActivityAnimDuration
                     animations:^{
                         [[self activityLabel] setAlpha:0.0f];
                         if (hideActivity) {
                             [[self indicator] setAlpha:0.0f];
                         }
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

#pragma mark - Show

- (void)showInView:(UIView *)view
          withText:(NSString *)text
       successMark:(BOOL)showSuccessMark
        completion:(void (^)(void))completion {
    
    [self setFrame:[view bounds]];
    [self setNeedsLayout];
    [self setAlpha:0.0f]; // make sure it's not visible before adding to view
    [self showSuccessMarkAnimated:NO completion:nil];
    [view addSubview:self];
    [self showWithText:text activity:NO completion:completion];
    
}

- (void)showInView:(UIView*)view completion:(void(^)(void))completion {
    [self showInView:view withText:nil activity:YES completion:completion];
}

- (void)showInView:(UIView*)view
          withText:(NSString*)text
          activity:(BOOL)activity
        completion:(void(^)(void))completion {
    
    [self setFrame:[view bounds]];
    [self setNeedsLayout];
    [self setAlpha:0.0f]; // make sure it's not visible before adding to view
    [view addSubview:self];
    [self showWithText:text activity:activity completion:completion];
}

- (void)showInView:(UIView*)view activity:(BOOL)activity completion:(void(^)(void))completion {
    [self showInView:view withText:nil activity:activity completion:completion];
}

- (void)showWithText:(NSString*)text
            activity:(BOOL)activity
          completion:(void(^)(void))completion {
    
    [self setAlpha:0.0f];
    [self setHidden:NO];
    [[self indicator] stop];
    
    if (text != nil) {
        [[self activityLabel] setText:text];
        [self setNeedsLayout]; // update, based on text
        [[self activityLabel] setAlpha:1.0f];
    }
    
    [UIView animateWithDuration:kHEMActivityAnimDuration
                     animations:^{
                         [self setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         if (activity) {
                             [[self indicator] start];
                         }
                         [self setShowing:YES];
                         if (completion) completion ();
                     }];
}

#pragma mark - Dismiss

- (void)dismissWithResultText:(NSString*)text
              showSuccessMark:(BOOL)showMark
                       remove:(BOOL)remove
                   completion:(void(^)(void))completion {
    
    [self updateText:text hideActivity:YES completion:^(BOOL finished) {
        [[self indicator] stop];
        if (showMark) {
            [self showSuccessMarkAnimated:YES completion:^(BOOL finished) {
                [self delayDismissWithCompletion:completion];
            }];
        } else {
            [self delayDismissWithCompletion:completion];
        }
    }];
    
}

- (void)delayDismissWithCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:kHEMActivityAnimDuration
                          delay:kHEMActivityResultDisplayTime
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self activityLabel] setText:nil];
                         [[self successMarkView] removeFromSuperview];
                         [self setHidden:YES];
                         
                         if (remove) {
                             [self removeFromSuperview];
                         }
                         
                         [self setShowing:NO];
                         if (completion) completion();
                     }];
}

@end
