//
//  HEMTimelineTopBarView.m
//  Sense
//
//  Created by Delisa Mason on 7/1/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineTopBarView.h"

@interface HEMTimelineTopBarView ()
@property (nonatomic, strong) UIView *blurView;
@end

@implementation HEMTimelineTopBarView

- (void)awakeFromNib {
    if (NSClassFromString(@"UIVisualEffectView") != nil) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [self insertSubview:blurView atIndex:0];
        self.blurView = blurView;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.blurView.alpha = 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.blurView.frame = self.bounds;
}

- (void)setVisualEffectsEnabled:(BOOL)enabled {
    if (NSClassFromString(@"UIVisualEffectView") != nil) {
        UIVisualEffectView *blurView = (id)self.blurView;
        CGFloat alpha = enabled ? 1 : 0;
        if (alpha != blurView.alpha) {
            [UIView animateWithDuration:0.25f
                             animations:^{
                               blurView.alpha = alpha;
                             }];
        }
    }
}

- (BOOL)areVisualEffectsEnabled {
    if (NSClassFromString(@"UIVisualEffectView") != nil) {
        return self.blurView.alpha > 0;
    }
    return NO;
}

@end
