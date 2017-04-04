//
//  HEMEventBubbleView.m
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>
#import "Sense-Swift.h"
#import "HEMEventBubbleView.h"
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
@property (nonatomic, strong) UIColor* highlightedBgColor;
@property (nonatomic, strong) UIColor* normalBgColor;
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
CGFloat const HEMEventBubbleShadowOpacity = 0.25f;
CGFloat const HEMEventTimestampMaximumHeight = 24.0f;

+ (NSDictionary*)messageAttributes {
    UIColor* textColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    UIColor* textHighlightedColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextHighlightedColor];
    UIFont* textFont = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.lineSpacing = 2.f;
    style.maximumLineHeight = 18.f;
    style.minimumLineHeight = 18.f;
    return @{@(STRONG) : @{NSFontAttributeName : textFont,
                           NSParagraphStyleAttributeName : style,
                           NSForegroundColorAttributeName :textHighlightedColor},
             @(PARA) : @{NSFontAttributeName : textFont,
                         NSParagraphStyleAttributeName : style,
                         NSForegroundColorAttributeName : textColor},
             @(EMPH) : @{NSFontAttributeName : textFont,
                         NSParagraphStyleAttributeName : style,
                         NSForegroundColorAttributeName : textHighlightedColor}};
}

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text
                        timeText:(NSAttributedString *)time
                    showWaveform:(BOOL)visible {
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    CGFloat bubbleWidth = screenWidth - HEMEventBubbleRightMargin - HEMEventBubbleLeftMargin;
    CGFloat textPadding = HEMEventBubbleTextLeftMargin + HEMEventBubbleContentHorzMargin;
    CGFloat maxTextWidth = bubbleWidth - textPadding;
    if (time) {
        CGFloat timeWidth = [time sizeWithHeight:HEMEventTimestampMaximumHeight].width;
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
    [super awakeFromNib];
    
    self.normalBgColor = [SenseStyle colorWithAClass:[self class]
                                            property:ThemePropertyBackgroundColor];
    self.highlightedBgColor = [SenseStyle colorWithAClass:[self class]
                                                 property:ThemePropertyBackgroundHighlightedColor];
    self.layer.shadowRadius = 2.f;
    self.layer.shadowColor = [[UIColor tintColor] CGColor];
    self.layer.shadowOpacity = HEMEventBubbleShadowOpacity;
    self.layer.shadowOffset = CGSizeZero;
    self.cornerView.layer.cornerRadius = 3.f;
    self.cornerView.layer.masksToBounds = YES;

    self.layer.masksToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    self.cornerView.backgroundColor = self.normalBgColor;
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
        self.cornerView.backgroundColor = self.highlightedBgColor;
        [self setShadowVisible:NO];
    } else {
        [self setShadowVisible:YES];
        self.cornerView.backgroundColor = self.normalBgColor;
    }
}

- (void)setShadowVisible:(BOOL)visible {
    self.layer.shadowOpacity = visible ? HEMEventBubbleShadowOpacity : 0.0f;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    [self setShadowVisible:userInteractionEnabled];
}

- (void)showWaveformViews:(BOOL)visible {
    self.showingWaveforms = visible;
    self.topWaveformView.hidden = !visible;
    self.bottomWaveformView.hidden = !visible;
    [self invalidateIntrinsicContentSize];
}

@end
