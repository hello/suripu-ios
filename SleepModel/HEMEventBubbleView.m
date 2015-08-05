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

CGFloat const HEMEventBubbleTextWidthOffset = 121.f;
CGFloat const HEMEventBubbleWidthOffset = 50.f;
CGFloat const HEMEventBubbleTextHeightOffset = 28.f;
CGFloat const HEMEventBubbleMinimumHeight = 48.f;
CGFloat const HEMEventTimeLabelWidth = 40.f;
CGFloat const HEMEventBubbleShadowOpacity = 0.25f;

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text
                        timeText:(NSAttributedString *)time
                    showWaveform:(BOOL)visible {
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenSize);
    CGFloat textWidth = screenWidth - HEMEventBubbleTextWidthOffset - [time sizeWithWidth:HEMEventTimeLabelWidth].width;
    CGSize textSize = [text sizeWithWidth:textWidth];
    CGFloat width = screenWidth - HEMEventBubbleWidthOffset;
    CGFloat height = MAX(textSize.height + HEMEventBubbleTextHeightOffset, HEMEventBubbleMinimumHeight);
    if (visible) {
        height += HEMEventBubbleWaveformHeight;
    }
    return CGSizeMake(width, height);
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
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.cornerView.backgroundColor = [UIColor timelineEventSelectedBackgroundColor];
        [self setShadowVisible:NO];
    } else {
        [self setShadowVisible:YES];
        self.cornerView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setShadowVisible:(BOOL)visible {
    self.layer.shadowOpacity = visible ? HEMEventBubbleShadowOpacity : 0.0f;
}

- (void)showWaveformViews:(BOOL)visible {
    self.showingWaveforms = visible;
    self.topWaveformView.hidden = !visible;
    self.bottomWaveformView.hidden = !visible;
    [self invalidateIntrinsicContentSize];
}

@end
