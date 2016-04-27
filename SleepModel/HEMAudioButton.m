//
//  HEMAudioButton.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMAudioButton.h"
#import "HEMActivityIndicatorView.h"
#import "HEMStyle.h"

static CGFloat const HEMAudioButtonImageRightInset = 4.0f;
static CGFloat const HEMAudioButtonTitleLeftInset = 8.0f;

@interface HEMAudioButton()

@property (nonatomic, strong) HEMActivityIndicatorView* loadingView;

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
    [self setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, HEMAudioButtonImageRightInset)];
    [[self titleLabel] setFont:[UIFont audioPreviewButtonTitleFont]];
    [self setTitleColor:[UIColor audioPreviewButtonTitleColor] forState:UIControlStateNormal];
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
        UIImage* playIcon = [UIImage imageNamed:@"miniPlayButton"];
        CGRect loadingFrame = CGRectZero;
        loadingFrame.size = playIcon.size;
        _loadingView = [[HEMActivityIndicatorView alloc] initWithFrame:loadingFrame];
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
            break;
        case HEMAudioButtonStatePlaying:
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [[self imageView] setHidden:NO];
            [self setTitle:[NSLocalizedString(@"sounds.audio.stop", nil) uppercaseString]
                  forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"miniStopButton"]
                  forState:UIControlStateNormal];
            [self adjustSize];
            break;
        default:
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [[self imageView] setHidden:NO];
            [self setTitle:[NSLocalizedString(@"sounds.audio.preview", nil) uppercaseString]
                  forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"miniPlayButton"]
                  forState:UIControlStateNormal];
            [self adjustSize];
            break;
    }

}

- (void)adjustSize {
    [self sizeToFit];
    CGRect frame = [self frame];
    frame.size.width += HEMAudioButtonTitleLeftInset;
    [self setFrame:frame];
}

@end
