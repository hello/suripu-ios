//
//  HEMTappableView.m
//  Sense
//
//  Created by Jimmy Lu on 8/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTappableView.h"

static CGFloat const HEMTappableMinimumPressDuration = 0.1f;
static CGFloat const HEMTappableAllowablePressMovement = 5.0f;

@interface HEMTappableView()

@property (nonatomic, strong) UIGestureRecognizer *tapGesture;
@property (nonatomic, weak)   id target;
@property (nonatomic, assign) SEL action;

@end

@implementation HEMTappableView

- (id)init {
    self = [super init];
    if (self) {
        [self configureTapGesture];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureTapGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureTapGesture];
    }
    return self;
}

#pragma mark - Gestures

- (void)configureTapGesture {
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress setMinimumPressDuration:HEMTappableMinimumPressDuration];
    [longPress setAllowableMovement:HEMTappableAllowablePressMovement];
    [longPress addTarget:self action:@selector(didPress:)];
    [self setTapGesture:longPress];
    [self addGestureRecognizer:[self tapGesture]];
    
    [self setUserInteractionEnabled:YES];
}

/**
 * @discussion
 * Handle various states to highlight or unhighlight the view and call the delegate
 * if one is set when the gesture is officially triggered.  This can be handled by
 * having a UIButton on top of the view or inheriting from UIControl, but strangely
 * adding a view on top of itself, from a subclass, might cause problems and will
 * add to the view hierachy that we want to avoid.  UIControl seems like overkill
 * as well and thus we are using a long press gesture that provides better control
 * (at least over a UITapGesture) when being dragged.
 */
- (void)didPress:(UIGestureRecognizer*)gesture {
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
            [self setHighlighted:YES];
            break;
        case UIGestureRecognizerStateEnded: {
            [self setHighlighted:NO];
            CGPoint location = [gesture locationInView:self];
            if (CGRectContainsPoint([self bounds], location)) {
                [[self tapDelegate] didTapOnView:self];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [gesture locationInView:self];
            if ([self isHighlighted]
                && !CGRectContainsPoint([self bounds], location)) {
                [self setHighlighted:NO];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self setHighlighted:NO];
            break;
        default:
            break;
    }
}

@end
