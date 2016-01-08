//
//  HEMEventBubbleView.m
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMEventBubbleView.h"
#import "UIColor+HEMStyle.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMScreenUtils.h"

CGFloat const HEMEventBubbleWaveformHeight = 26.f;

@interface HEMEventBubbleView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIView *cornerView;
@property (nonatomic, weak) IBOutlet UIImageView *topWaveformView;
@property (nonatomic, weak) IBOutlet UIImageView *bottomWaveformView;
@property (nonatomic, getter=isShowingWaveforms, readwrite) BOOL showingWaveforms;
@end

@implementation HEMEventBubbleView

// values more or less matches the xib file for the cell as well as the sketch
// file.  If any of the two changes, be sure to update here
CGFloat const HEMEventBubbleTextLeftMargin = 52.0f;
CGFloat const HEMEventBubbleTextPaddingToTime = 8.0f;
CGFloat const HEMEventBubbleRightMargin = 40.f;
CGFloat const HEMEventBubbleLeftMargin = 8.f;
CGFloat const HEMEventBubbleContentHorzMargin = 8.f;
CGFloat const HEMEventBubbleTextHeightOffset = 26.f;
CGFloat const HEMEventBubbleMinimumHeight = 48.f;
CGFloat const HEMEventTimeLabelWidth = 48.f;
CGFloat const HEMEventBubbleShadowOpacity = 0.25f;

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text
                        timeText:(NSAttributedString *)time
                    showWaveform:(BOOL)visible {
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    CGFloat bubbleWidth = screenWidth - HEMEventBubbleRightMargin - HEMEventBubbleLeftMargin;
    CGFloat textPadding = HEMEventBubbleTextLeftMargin + HEMEventBubbleContentHorzMargin;
    CGFloat maxTextWidth = bubbleWidth - textPadding;
    if (time) {
        CGFloat timeWidth = [time sizeWithWidth:HEMEventTimeLabelWidth].width;
        maxTextWidth = maxTextWidth - timeWidth - HEMEventBubbleTextPaddingToTime;
    }
    CGSize textSize = [text sizeWithWidth:maxTextWidth];
    CGFloat height = MAX(textSize.height + HEMEventBubbleTextHeightOffset, HEMEventBubbleMinimumHeight);
    if (visible) {
        height += HEMEventBubbleWaveformHeight;
    }
    return CGSizeMake(ceilCGFloat(bubbleWidth), ceilCGFloat(height));
}

- (void)awakeFromNib {
    self.layer.shadowRadius = 2.f;
    self.layer.shadowColor = [[UIColor tintColor] CGColor];
    self.layer.shadowOpacity = HEMEventBubbleShadowOpacity;
    self.layer.shadowOffset = CGSizeZero;
    self.cornerView.layer.cornerRadius = 3.f;
    self.cornerView.layer.masksToBounds = YES;

    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    self.cornerView.backgroundColor = [UIColor whiteColor];
    self.showingWaveforms = NO;

    self.accessibilityLabel = NSLocalizedString(@"sleep-event.accessibility-label", nil);
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.isAccessibilityElement = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cornerView.frame = self.bounds;
}

- (CGSize)intrinsicContentSize {
    return [[self class] sizeWithAttributedText:self.textLabel.attributedText
                                       timeText:self.timeLabel.attributedText
                                   showWaveform:[self isShowingWaveforms]];
}

- (void)setMessageText:(NSAttributedString *)message timeText:(NSAttributedString *)time {
    self.textLabel.attributedText = message;
    self.timeLabel.attributedText = time;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
    self.accessibilityValue = [NSString stringWithFormat:NSLocalizedString(@"sleep-event.accessibility-value.format", nil), [time string], [message string]];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.cornerView.backgroundColor = [UIColor timelineSelectedBackgroundColor];
        [self setShadowVisible:NO];
    } else {
        [self setShadowVisible:YES];
        self.cornerView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setShadowVisible:(BOOL)visible {
    self.layer.shadowOpacity = visible ? HEMEventBubbleShadowOpacity : 0.0f;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.accessibilityHint = userInteractionEnabled ? NSLocalizedString(@"sleep-event.accessibility-hint", nil) : nil;
    self.accessibilityTraits = userInteractionEnabled ? UIAccessibilityTraitButton : UIAccessibilityTraitNone;
    [self setShadowVisible:userInteractionEnabled];
}

- (void)showWaveformViews:(BOOL)visible {
    self.showingWaveforms = visible;
    self.topWaveformView.hidden = !visible;
    self.bottomWaveformView.hidden = !visible;
    [self invalidateIntrinsicContentSize];
}

@end
