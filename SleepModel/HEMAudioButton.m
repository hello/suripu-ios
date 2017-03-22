//
//  HEMAudioButton.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMAudioButton.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMAudioButtonImageRightInset = 4.0f;
static CGFloat const HEMAudioButtonTitleLeftInset = 8.0f;
static CGFloat const HEMAudioButtonAnimeLabelFadeDuration = 0.2f;

@interface HEMAudioButton()

@property (nonatomic, strong) HEMActivityIndicatorView* loadingView;
@property (nonatomic, strong) UIImage* playIcon;
@property (nonatomic, strong) UIImage* stopIcon;

@end

@implementation HEMAudioButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

- (void)configureDefaults {
    UIImage* playIcon = [UIImage imageNamed:@"miniPlayButton"];
    [self setPlayIcon:[playIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    UIImage* stopIcon = [UIImage imageNamed:@"miniStopButton"];
    [self setStopIcon:[stopIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    UIColor* tintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTintColor];
    [self setTintColor:tintColor];
    
    UIColor* textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* textFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    
    [self setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, HEMAudioButtonImageRightInset)];
    [[self titleLabel] setFont:textFont];
    [self setTitleColor:textColor forState:UIControlStateNormal];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, HEMAudioButtonTitleLeftInset, 0.0f, 0.0f)];
    [self putIconToTheRightOfTitle];
}

- (void)putIconToTheRightOfTitle {
    [self setTransform:CGAffineTransformMakeScale(-1.0f, 1.0f)];
    [[self titleLabel] setTransform:CGAffineTransformMakeScale(-1.0f, 1.0f)];
    [[self imageView] setTransform:CGAffineTransformMakeScale(-1.0f, 1.0f)];
}

- (HEMActivityIndicatorView*)loadingView {
    if (!_loadingView) {
        CGRect loadingFrame = CGRectZero;
        loadingFrame.size = [self playIcon].size;
        UIImage* loadingIndicator = [UIImage imageNamed:@"settingsLoader"];
        _loadingView = [[HEMActivityIndicatorView alloc] initWithImage:loadingIndicator
                                                              andFrame:loadingFrame];
        [_loadingView setHidden:YES];
    }
    return _loadingView;
}

- (void)layoutIndicatorIfNeeded {
    if ([[self loadingView] superview]) {
        CGRect loadingFrame = [[self loadingView] frame];
        loadingFrame.origin.x = CGRectGetMinX([[self imageView] frame]);
        loadingFrame.origin.y = CGRectGetMinY([[self imageView] frame]);
        [[self loadingView] setFrame:loadingFrame];
    }
}

- (void)setAudioState:(HEMAudioButtonState)audioState {
    if (_audioState == audioState) {
        return;
    }
    
    _audioState = audioState;

    switch (audioState) {
        case HEMAudioButtonStateLoading:
            [self addSubview:[self loadingView]];
            [self layoutIndicatorIfNeeded];
            [[self loadingView] start];
            [[self loadingView] setHidden:NO];
            [[self imageView] setHidden:YES];
            [self fadeLabel:0.0f];
            break;
        case HEMAudioButtonStatePlaying:
            [self fadeLabel:1.0f];
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [[self imageView] setHidden:NO];
            [self setTitle:[NSLocalizedString(@"sounds.audio.stop", nil) uppercaseString]
                  forState:UIControlStateNormal];
            [self setImage:[self stopIcon] forState:UIControlStateNormal];
            [self adjustSize];
            break;
        default:
            [self fadeLabel:1.0f];
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [[self imageView] setHidden:NO];
            [self setTitle:[NSLocalizedString(@"sounds.audio.preview", nil) uppercaseString]
                  forState:UIControlStateNormal];
            [self setImage:[self playIcon] forState:UIControlStateNormal];
            [self adjustSize];
            break;
    }

}
    
- (void)fadeLabel:(CGFloat)alpha {
    if ([[self titleLabel] alpha] != alpha) {
        [UIView animateWithDuration:HEMAudioButtonAnimeLabelFadeDuration animations:^{
            [[self titleLabel] setAlpha:alpha];
        }];
    }
}

- (void)adjustSize {
    CGRect frame = [self frame];
    
    CGSize sizeConstraint = CGSizeMake(MAXFLOAT, CGRectGetHeight(frame));
    CGFloat sizedWidth = [self sizeThatFits:sizeConstraint].width;
    
    frame.size.width = sizedWidth + HEMAudioButtonTitleLeftInset;
    
    [self setFrame:frame];
}

@end
