//
//  HEMVolumeSlider.m
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVolumeSlider.h"

static CGFloat const kHEMVolumeSliderBarMinHeight = 40.0f;
static CGFloat const kHEMVolumeSliderBarWidth = 2.0f;
static CGFloat const kHEMVolumeSliderBarAnimeDuration = 0.25f;

@interface HEMVolumeSlider()

@end

@implementation HEMVolumeSlider

- (void)render {
    NSArray* gestures = [[self gestureRecognizers] mutableCopy];
    for (UIGestureRecognizer* gesture in gestures) {
        [self removeGestureRecognizer:gesture];
    }
    
    [self setClipsToBounds:YES];
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat fullHeight = CGRectGetHeight([self bounds]);
    NSInteger highlightIndex = [self currentVolume] - 1;
    int i;
    
    for (i = 0; i < [self maxVolumeLevel]; i++) {
        BOOL highlight = i <= highlightIndex;
        UIView* bar = [self barWithHighlight:highlight atIndex:i];
        [self addSubview:bar];
        
        [bar setTransform:CGAffineTransformMakeTranslation(0.0f, fullHeight)];
        [UIView animateWithDuration:kHEMVolumeSliderBarAnimeDuration animations:^{
            [bar setTransform:CGAffineTransformIdentity];
        }];
    }
    
    UIPanGestureRecognizer* panGesture = [UIPanGestureRecognizer new];
    [panGesture addTarget:self action:@selector(sliding:)];
    [self addGestureRecognizer:panGesture];
}

- (UIView*)barWithHighlight:(BOOL)highlight atIndex:(NSInteger)index {
    CGFloat fullWidth = CGRectGetWidth([self bounds]);
    CGFloat fullHeight = CGRectGetHeight([self bounds]);
    CGFloat heightRange = fullHeight - kHEMVolumeSliderBarMinHeight;
    CGFloat heightIncreasePerBar = heightRange / [self maxVolumeLevel];
    CGFloat barHeight = kHEMVolumeSliderBarMinHeight + (heightIncreasePerBar * index);
    CGFloat spacingForBars = kHEMVolumeSliderBarWidth * [self maxVolumeLevel];
    CGFloat spacingBetweenBars = (fullWidth - spacingForBars) / ([self maxVolumeLevel] - 1);
    
    CGRect barFrame = CGRectZero;
    barFrame.size.height = barHeight;
    barFrame.size.width = kHEMVolumeSliderBarWidth;
    barFrame.origin.x =  (spacingBetweenBars + kHEMVolumeSliderBarWidth) * index;
    barFrame.origin.y = fullHeight - barHeight;
    
    UIColor* barColor = highlight ? [self highlightColor] : [self normalColor];
    UIView* bar = [[UIView alloc] initWithFrame:barFrame];
    [bar setBackgroundColor:barColor];
    [bar setTag:index + 1]; // represents volume level

    return bar;
}

- (BOOL)isRendered {
    return [[self subviews] count] > 0;
}

- (void)sliding:(UIPanGestureRecognizer*)panGesture {
    switch ([panGesture state]) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            [self updateFromPoint:[panGesture locationInView:self]];
            [[self changeDelegate] didChangeVolumeTo:[self currentVolume] fromSlider:self];
            break;
        default:
            break;
    }
}

- (void)updateFromPoint:(CGPoint)point {
    BOOL highlight = NO;
    UIColor* barColor;
    NSInteger selectedVolume = [self currentVolume];
    
    for (UIView* bar in [self subviews]) {
        highlight = CGRectGetMaxX([bar frame]) < point.x || [bar tag] == 1; // first bar is always highlighted
        barColor = highlight ? [self highlightColor] : [self normalColor];
        [bar setBackgroundColor:barColor];
        if (highlight) { // will always be the highest
            selectedVolume = [bar tag];
        }
    }
    
    [self setCurrentVolume:selectedVolume];
}

@end
