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

static CGFloat const HEMHandholdingGestureSize = 50.0f;
static CGFloat const HEMHandholdingMessageAnimDuration = 0.5f;

@interface HEMHandholdingView()

@property (nonatomic, strong) HEMHintGestureView* gestureView;
@property (nonatomic, strong) HEMHintMessageView* messageView;
@property (nonatomic, weak)   UIView* viewUnderneath;

@end

@implementation HEMHandholdingView

- (id)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint([[self messageView] frame], point)) {
        return [super hitTest:point withEvent:event];
    } else {
        UIView* view = [[self viewUnderneath] hitTest:point withEvent:event];
        [self removeFromSuperview];
        return view;
    }
}

- (void)showInView:(UIView*)view {
    CGFloat halfGestureSize = HEMHandholdingGestureSize / 2;
    CGRect gestureFrame = CGRectZero;
    gestureFrame.size = CGSizeMake(HEMHandholdingGestureSize, HEMHandholdingGestureSize);
    gestureFrame.origin.x = [self gestureStartCenter].x - halfGestureSize;
    gestureFrame.origin.y = [self gestureStartCenter].y - halfGestureSize;
    
    [self setGestureView:[[HEMHintGestureView alloc] initWithFrame:gestureFrame
                                                     withEndCenter:[self gestureEndCenter]]];
    
    
    
    [self setMessageView:[[HEMHintMessageView alloc] initWithMessage:[self message]
                                                  constrainedToWidth:CGRectGetWidth([view bounds])]];
    [[[self messageView] dismissButton] addTarget:self
                                           action:@selector(animateOut)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    CGRect messageViewFrame = [[self messageView] frame];
    CGFloat messageHeight = CGRectGetHeight([[self messageView] bounds]);
    
    if ([self anchor] == HEMHHDialogAnchorBottom) {
        messageViewFrame.origin.y = CGRectGetHeight([view bounds]) + messageHeight;
    } else {
        messageViewFrame.origin.y -= messageHeight;
    }

    [[self messageView] setFrame:messageViewFrame];
     
    [self setFrame:[view bounds]];
    [self addSubview:[self gestureView]];
    [self addSubview:[self messageView]];
    [self setViewUnderneath:[[view subviews] lastObject]];
    [view addSubview:self];
    [self animateIn];
}

- (void)animateIn {
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
    [[self gestureView] endAnimation];
    
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
