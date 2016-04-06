//
//  HEMAudioButton.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMAudioButton.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMAudioButtonImageRightOffset = 4.0f;

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
    [self setContentEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, HEMAudioButtonImageRightOffset)];
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
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
            [self setImage:nil forState:UIControlStateNormal];
            break;
        case HEMAudioButtonStatePlaying:
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [self setImage:[UIImage imageNamed:@"miniStopButton"]
                  forState:UIControlStateNormal];
            break;
        default:
            [[self loadingView] removeFromSuperview];
            [[self loadingView] setHidden:YES];
            [self setImage:[UIImage imageNamed:@"miniPlayButton"]
                  forState:UIControlStateNormal];
            break;
    }
}

@end
