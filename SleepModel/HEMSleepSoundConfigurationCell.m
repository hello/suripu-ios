//
//  HEMSleepSoundConfigurationCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMSleepSoundConfigurationCell.h"

static CGFloat const HEMSleepSoundConfCellSeparatorHeight = 0.5f;
static CGFloat const HEMSleepSoundConfAnimDuration = 0.5f;
static CGFloat const HEMSleepSoundGraphAnimeDelay = 0.25f;
static CGFloat const HEMSleepSoundGraphMinScale = 0.3f;

@interface HEMSleepSoundConfigurationCell()

@end

@implementation HEMSleepSoundConfigurationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self titleSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
    [[self soundSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
    [[self durationSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
    
    static NSString* leftImageKey = @"sense.sound.graph.left";
    static NSString* rightImageKey = @"sense.sound.graph.right";
    UIImage* soundGraphLeft = [SenseStyle imageWithAClass:[self class]
                                             propertyName:leftImageKey];
    UIImage* soundGraphRight = [SenseStyle imageWithAClass:[self class]
                                             propertyName:rightImageKey];
    UIImage* soundIcon = [[[self soundImageView] image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* durationIcon = [[[self durationImageView] image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* volumeIcon = [[[self volumeImageView] image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [[self soundGraphLeftView] setImage:soundGraphLeft];
    [[self soundGraphRightView] setImage:soundGraphRight];
    [[self soundImageView] setImage:soundIcon];
    [[self durationImageView] setImage:durationIcon];
    [[self volumeImageView] setImage:volumeIcon];
    
    [[self overlay] applyDisabledOverlayStyle];
    [[self overlay] setAlpha:1.0f];
    [[self soundAccessoryView] setAlpha:0.0f];
    [[self durationAccessoryView] setAlpha:0.0f];
    [[self volumeAccessoryView] setAlpha:0.0f];
    
    [[self soundValueLabel] setAlpha:0.0f];
    [[self durationValueLabel] setAlpha:0.0f];
    [[self volumeValueLabel] setAlpha:0.0f];
    
    [self applyStyle];
    
    [self deactivate:YES];
}

- (void)deactivate:(BOOL)deactivate {
    [self setUserInteractionEnabled:!deactivate];
    [[self overlay] setHidden:NO];
    
    [UIView animateWithDuration:HEMSleepSoundConfAnimDuration animations:^{
        [[self overlay] setAlpha:deactivate ? 1.0f : 0.0f];
        [[self soundAccessoryView] setAlpha:deactivate ? 0.0f : 1.0f];
        [[self durationAccessoryView] setAlpha:deactivate ? 0.0f : 1.0f];
        [[self volumeAccessoryView] setAlpha:deactivate ? 0.0f : 1.0f];
        [[self soundValueLabel] setAlpha:1.0f];
        [[self durationValueLabel] setAlpha:1.0f];
        [[self volumeValueLabel] setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [[self overlay] setHidden:!deactivate];
    }];
}

- (void)setPlaying:(BOOL)playing {
    [self deactivate:playing];
    
    if (!playing) {
        [self stopSoundGraphAnimation];
    }
    
    UIView* container = [[self titleLabel] superview];
    CGFloat height = CGRectGetHeight([container bounds]);
    [UIView animateWithDuration:HEMSleepSoundConfAnimDuration animations:^{
        if (playing) {
            [[self playingLabel] setAlpha:1.0f];
            [[self playingLabelTopConstraint] setConstant:0.0f];
            [[self titleTopConstraint] setConstant:height];
            [[self titleLabel] setAlpha:0.0f];
        } else {
            [[self playingLabel] setAlpha:0.0f];
            [[self playingLabelTopConstraint] setConstant:-height];
            [[self titleTopConstraint] setConstant:0.0f];
            [[self titleLabel] setAlpha:1.0f];
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (playing) {
            [self startSoundGraphAnimation];
        }
    }];
}

- (void)animateSoundGraph:(UIImageView*)graphView {
    CALayer* layer = [graphView layer];
    NSString* key = @"transform.scale.y";
    if (![layer animationForKey:key]) {
        CABasicAnimation* anime = [CABasicAnimation animationWithKeyPath:key];
        [anime setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [anime setFromValue:@1];
        [anime setToValue:@(HEMSleepSoundGraphMinScale)];
        [anime setDuration:HEMSleepSoundConfAnimDuration];
        [anime setRepeatCount:INFINITY];
        [anime setRemovedOnCompletion:NO];
        [anime setAutoreverses:YES];
        [anime setFillMode:kCAFillModeForwards];
        [layer addAnimation:anime forKey:key];
    }
}

- (void)startSoundGraphAnimation {
    [UIView animateWithDuration:HEMSleepSoundConfAnimDuration animations:^{
        [[self soundGraphLeftView] setAlpha:1.0f];
        [[self soundGraphRightView] setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [self animateSoundGraph:[self soundGraphLeftView]];
        
        int64_t delay = HEMSleepSoundGraphAnimeDelay * NSEC_PER_SEC;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self animateSoundGraph:[self soundGraphRightView]];
        });
    }];
}

- (void)stopSoundGraphAnimation {
    [UIView animateWithDuration:HEMSleepSoundConfAnimDuration animations:^{
        [[self soundGraphLeftView] setAlpha:0.0f];
        [[self soundGraphRightView] setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [[[self soundGraphRightView] layer] removeAllAnimations];
        [[[self soundGraphLeftView] layer] removeAllAnimations];
    }];
}

- (void)applyStyle {
    [super applyStyle];
    
    UIFont* textFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* detailColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIColor* tintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTintColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    
    [[self soundGraphLeftView] setBackgroundColor:[self backgroundColor]];
    [[self soundGraphRightView] setBackgroundColor:[self backgroundColor]];
    [[self overlay] applyDisabledOverlayStyle];
    [[self titleLabel] setBackgroundColor:[self backgroundColor]];
    [[self titleLabel] setTextColor:titleColor];
    [[self titleLabel] setFont:titleFont];
    [[self playingLabel] setBackgroundColor:[self backgroundColor]];
    [[self playingLabel] setTextColor:titleColor];
    [[self playingLabel] setFont:titleFont];
    [[self titleSeparator] applySeparatorStyle];
    [[self soundImageView] setTintColor:tintColor];
    [[self soundLabel] setFont:textFont];
    [[self soundLabel] setTextColor:textColor];
    [[self soundValueLabel] setTextColor:detailColor];
    [[self soundValueLabel] setFont:textFont];
    [[self soundSeparator] applySeparatorStyle];
    [[self durationImageView] setTintColor:tintColor];
    [[self durationLabel] setTextColor:textColor];
    [[self durationLabel] setFont:textFont];
    [[self durationValueLabel] setFont:textFont];
    [[self durationValueLabel] setTextColor:detailColor];
    [[self durationSeparator] applySeparatorStyle];
    [[self volumeImageView] setTintColor:tintColor];
    [[self volumeLabel] setTextColor:textColor];
    [[self volumeLabel] setFont:textFont];
    [[self volumeValueLabel] setFont:textFont];
    [[self volumeValueLabel] setTextColor:detailColor];
}

@end
