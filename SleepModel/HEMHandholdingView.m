//
//  HEMHandholdingOverlayView.m
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMHandholdingView.h"
#import "HEMHintGestureView.h"
#import "HEMHintMessageView.h"

CGFloat const HEMHandholdingGestureSize = 50.0f;
static CGFloat const HEMHandholdingMessageAnimDuration = 0.5f;

@interface HEMHandholdingView()

@property (nonatomic, strong) HEMHintGestureView* gestureView;
@property (nonatomic, strong) HEMHintMessageView* messageView;
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
        [self animateOut];
    }
    return onMessage;
}

#pragma mark - View set up and display

- (void)showInView:(UIView*)view dismissAction:(HEMHandHoldingDismissal)dismissal {
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

- (void)addMessageHintWithText:(NSString*)text withBounds:(CGRect)bounds {
    [self setMessageView:[[HEMHintMessageView alloc] initWithMessage:[self message]
                                                  constrainedToWidth:CGRectGetWidth(bounds)]];
    
    [[[self messageView] dismissButton] addTarget:self
                                           action:@selector(dismissFromButton)
                                 forControlEvents:UIControlEventTouchUpInside];
    
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
    if ([self dismissal]) {
        [self dismissal] ();
    }
    [self animateOut];
}

#pragma mark - Animations

- (void)animateIn {
    [self setDismissing:NO];
    
    if (![self messageView]) {
        [[self gestureView] startAnimation];
        return;
    }
    
    __block CGRect messageViewFrame = [[self messageView] frame];
    
    CGFloat y = 0.0f;
    if ([self anchor] == HEMHHDialogAnchorBottom) {
        y = CGRectGetHeight([self bounds]) - CGRectGetHeight(messageViewFrame);
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

- (void)animateOut {
    if ([self isDismissing]) {
        return;
    }
    
    [self setDismissing:YES];
    [[self gestureView] endAnimation];
    
    if (![self messageView]) {
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
                     }];
}

@end
