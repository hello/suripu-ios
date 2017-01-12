//
//  HEMHandholdingOverlayView.m
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import "NSString+HEMUtils.h"

#import "HEMHandholdingView.h"
#import "HEMHintGestureView.h"
#import "HEMHintMessageView.h"
#import "HEMStyle.h"

CGFloat const HEMHandholdingGestureSize = 50.0f;
static CGFloat const HEMHandholdingMessageAnimDuration = 0.5f;
static CGFloat const HEMHandholdingMessageOvalHPadding = 14.0f;
static CGFloat const HEMHandholdingMessageOvalVPadding = 7.0f;
static CGFloat const HEMHandholdingMessageOvalMargins = 24.0f;

@interface HEMHandholdingView()

@property (nonatomic, strong) HEMHintGestureView* gestureView;
@property (nonatomic, strong) UIView* messageView;
@property (nonatomic, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, copy) HEMHandHoldingDismissal dismissal;

@end

@implementation HEMHandholdingView

- (id)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL onMessage = CGRectContainsPoint([[self messageView] frame], point);
    if (!onMessage) {
        [self animateOut:nil];
    }
    return onMessage;
}

- (BOOL)isContentViewStillVisible:(UIView*)contentView {
    UIWindow* window = [[[UIApplication sharedApplication] windows] firstObject];
    CGRect contentFrame = [contentView convertRect:[contentView bounds] toView:window];
    CGRect windowFrame = [window frame];
    BOOL contentIsFullyInWindow = CGRectContainsRect(windowFrame, contentFrame);
    return ![contentView isHidden]
        && [contentView superview]
        && contentIsFullyInWindow;
}

#pragma mark - View set up and display

- (void)showGestureWithMessageInView:(UIView*)view
                     fromContentView:(UIView*)contentView
                       dismissAction:(HEMHandHoldingDismissal)dismissal {
    
    [self setDismissal:dismissal];
    
    CGFloat halfGestureSize = HEMHandholdingGestureSize / 2;
    CGRect gestureFrame = CGRectZero;
    gestureFrame.size = CGSizeMake(HEMHandholdingGestureSize, HEMHandholdingGestureSize);
    gestureFrame.origin.x = [self gestureStartCenter].x - halfGestureSize;
    gestureFrame.origin.y = [self gestureStartCenter].y - halfGestureSize;
    
    [self setGestureView:[[HEMHintGestureView alloc] initWithFrame:gestureFrame
                                                     withEndCenter:[self gestureEndCenter]]];
    
    if (CGPointEqualToPoint([self gestureStartCenter], [self gestureEndCenter])) {
        [[self gestureView] setAnimation:HEMHintGestureAnimationPulsate];
    }
    
    [self setFrame:[view bounds]];
    [self addSubview:[self gestureView]];
    
    if ([self message]) {
        [self addMessageHintWithText:[self message] withBounds:[view bounds]];
    }
    
    [view addSubview:self];
    [self animateIn];
    
}

- (void)showOnlyMessageIn:(UIView*)view
          fromContentView:(UIView*)contentView
            dismissAction:(HEMHandHoldingDismissal)dimissal {
    [self setDismissal:dimissal];
    
    CGFloat cornerRadius = 0.0f;
    CGRect labelFrame = CGRectZero;
    
    CGFloat containerWidth = CGRectGetWidth([view bounds]);
    UIFont* messageFont = [UIFont body];
    NSTextAlignment alignment = NSTextAlignmentLeft;
    
    switch ([self messageStyle]) {
        default:
        case HEMHHMessageStyleFull:
            labelFrame.size.width = containerWidth;
            labelFrame.size.height = [[self message] heightBoundedByWidth:containerWidth
                                                                usingFont:messageFont];
            break;
        case HEMHHMessageStyleOval: {
            NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
            [style setAlignment:NSTextAlignmentCenter];
            
            NSDictionary* attributes = @{NSFontAttributeName : messageFont,
                                         NSParagraphStyleAttributeName : style};
            
            CGFloat maxWidth = containerWidth - (HEMHandholdingMessageOvalMargins * 2);
            CGSize textSize = [[self message] sizeBoundedByWidth:maxWidth attriburtes:attributes];
            CGFloat labelHeight = textSize.height + (HEMHandholdingMessageOvalVPadding * 2);
            CGFloat labelWidth = textSize.width + (HEMHandholdingMessageOvalHPadding * 2);
            CGFloat x = (containerWidth - labelWidth) / 2.0f;
            
            labelFrame.size.width = labelWidth;
            labelFrame.size.height = labelHeight;
            labelFrame.origin.x = MAX(HEMHandholdingMessageOvalMargins, x);
            
            if ([self anchor] == HEMHHDialogAnchorTop) {
                labelFrame.origin.y = HEMHandholdingMessageOvalMargins;
            } else {
                labelFrame.origin.y = CGRectGetHeight([view bounds]) - labelHeight - HEMHandholdingMessageOvalMargins;
            }
            
            cornerRadius = labelHeight / 2.0f;
            alignment = NSTextAlignmentCenter;
            break;
        }
    }
    
    UILabel* plainLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [plainLabel setBackgroundColor:[UIColor blue6]];
    [plainLabel setFont:messageFont];
    [plainLabel setText:[self message]];
    [plainLabel setTextColor:[UIColor whiteColor]];
    [plainLabel setTextAlignment:alignment];
    [[plainLabel layer] setCornerRadius:cornerRadius];
    [plainLabel setClipsToBounds:YES];
    [plainLabel setAlpha:0.0f];
    
    [self setFrame:[view bounds]];
    [self setMessageView:plainLabel];
    [self addSubview:plainLabel];
    [view addSubview:self];
    [self fadeMessageIn:YES];
}

- (void)showInView:(UIView*)view
   fromContentView:(UIView*)contentView
     dismissAction:(HEMHandHoldingDismissal)dismissal {
    
    if (![self isContentViewStillVisible:contentView]) {
        if (dismissal) {
            dismissal (NO);
        }
        return;
    }
    
    if (CGPointEqualToPoint(CGPointZero, [self gestureStartCenter])
        && CGPointEqualToPoint(CGPointZero, [self gestureEndCenter])) {
        [self showOnlyMessageIn:view
                fromContentView:contentView
                  dismissAction:dismissal];
    } else {
        [self showGestureWithMessageInView:view
                           fromContentView:contentView
                             dismissAction:dismissal];
    }
}

- (void)addMessageHintWithText:(NSString*)text withBounds:(CGRect)bounds {
    HEMHintMessageView* messageView = [[HEMHintMessageView alloc] initWithMessage:[self message]
                                                               constrainedToWidth:CGRectGetWidth(bounds)];
    [[messageView dismissButton] addTarget:self
                                    action:@selector(dismissFromButton)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [self setMessageView:messageView];
    
    CGRect messageViewFrame = [[self messageView] frame];
    CGFloat messageHeight = CGRectGetHeight([[self messageView] bounds]);
    
    if ([self anchor] == HEMHHDialogAnchorBottom) {
        messageViewFrame.origin.y = CGRectGetHeight(bounds) + messageHeight;
    } else {
        messageViewFrame.origin.y -= messageHeight;
    }
    
    [[self messageView] setFrame:messageViewFrame];
    
    [self addSubview:[self messageView]];
}

#pragma mark - Actions

- (void)dismissFromButton {
    [self animateOut:^{
        if ([self dismissal]) {
            [self dismissal] (YES);
        }
    }];
}

#pragma mark - Animations

- (void)fadeMessageIn:(BOOL)show {
    [self setDismissing:NO];
    
    [[self messageView] setAlpha:show ? 0.0f : 1.0f];
    [UIView animateWithDuration:HEMHandholdingMessageAnimDuration animations:^{
        [[self messageView] setAlpha:show ? 1.0f : 0.0f];
    }];
}

- (void)animateIn {
    [self setDismissing:NO];
    
    if (![self messageView]) {
        [[self gestureView] startAnimation];
        return;
    }
    
    __block CGRect messageViewFrame = [[self messageView] frame];
    
    CGFloat y = 0.0f;
    if ([self anchor] == HEMHHDialogAnchorBottom) {
        y = CGRectGetHeight([self bounds]) - CGRectGetHeight(messageViewFrame) - [self messageYOffset];
    } else {
        y += [self messageYOffset];
    }
    
    [UIView animateWithDuration:HEMHandholdingMessageAnimDuration
                     animations:^{
                         messageViewFrame.origin.y = y;
                         [[self messageView] setFrame:messageViewFrame];
                     }
                     completion:^(BOOL finished) {
                         [[self gestureView] startAnimation];
                     }];
}

- (void)animateOut:(void(^)(void))completion {
    if ([self isDismissing]) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    [self setDismissing:YES];
    [[self gestureView] endAnimation];
    
    if (![self messageView]) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    __block CGRect messageViewFrame = [[self messageView] frame];
    
    CGFloat height = CGRectGetHeight(messageViewFrame);
    CGFloat y = 0.0f;
    if ([self anchor] == HEMHHDialogAnchorBottom) {
        y = CGRectGetHeight([self bounds]) + height;
    } else {
        y = -height;
    }
    
    [UIView animateWithDuration:HEMHandholdingMessageAnimDuration
                     animations:^{
                         messageViewFrame.origin.y = y;
                         [[self messageView] setFrame:messageViewFrame];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (completion) {
                             completion ();
                         }
                     }];
}

@end
