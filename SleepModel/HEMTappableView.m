//
//  HEMTappableView.m
//  Sense
//
//  Created by Jimmy Lu on 8/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTappableView.h"

@interface HEMTappableView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

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
    [self setUserInteractionEnabled:YES];
    [self setTapGesture:[[UITapGestureRecognizer alloc] init]];
    [[self tapGesture] addTarget:self action:@selector(didTap:)];
    [[self tapGesture] setDelegate:self];
    [self addGestureRecognizer:[self tapGesture]];
}

- (void)didTap:(UITapGestureRecognizer*)tap {
    [self setHighlighted:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    [self setHighlighted:YES];
    return YES;
}

/**
 * UITapGestureRecognizer, for whatever reason, does not send the cancelled
 * state to the target, which pushes the handling of that to the view as such
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setHighlighted:NO];
}

- (void)addTapTarget:(id)target action:(SEL)action {
    [[self tapGesture] addTarget:target action:action];
}

@end
