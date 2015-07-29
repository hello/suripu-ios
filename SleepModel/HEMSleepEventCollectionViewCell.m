
#import <AttributedMarkdown/markdown_peg.h>

#import "UIColor+HEMStyle.h"

#import "HEMSleepEventCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMTimelineLayoutAttributes.h"
#import "HEMMarkdown.h"
#import "HEMEventBubbleView.h"
#import "HEMWaveform.h"

@interface HEMSleepEventCollectionViewCell ()
@property (nonatomic) CGFloat cachedRatioFromCenter;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIView *waveformStoppedView;
@property (nonatomic, weak) IBOutlet UIView *waveformPlayingView;
@property (nonatomic, getter=isDisplayingAudioViews) BOOL displayAudioViews;
@end

@implementation HEMSleepEventCollectionViewCell

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text {
    return [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForEventMessageText]) trim];
}

- (void)layoutWithImage:(UIImage *)image message:(NSString *)text time:(NSAttributedString *)timeText {
    self.eventTypeImageView.image = image;
    [self.contentContainerView setMessageText:[[self class] attributedMessageFromText:text] timeText:timeText];
    self.contentContainerView.frame = [self containerFrame];
    [self layoutContainerViews];
    [self adjustContentsWithRatio:self.cachedRatioFromCenter];
}

- (void)displayAudioViewsWithWaveform:(HEMWaveform *)waveform {
    BOOL display = waveform != nil;
    self.displayAudioViews = display;
    self.playButton.hidden = !display;
    self.waveformStoppedView.hidden = !display;
    self.waveformPlayingView.hidden = !display;
}

- (void)applyLayoutAttributes:(HEMTimelineLayoutAttributes *)layoutAttributes {
    CGFloat ratio = layoutAttributes.ratioFromCenter;
    self.cachedRatioFromCenter = ratio;
    [self adjustContentsWithRatio:ratio];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self displayAudioViewsWithWaveform:nil];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self displayAudioViewsWithWaveform:nil];
    self.transform = CGAffineTransformIdentity;
    self.contentContainerView.alpha = 1;
    [self.contentContainerView setMessageText:nil timeText:nil];
}

- (void)prepareForEntryAnimation {
    [super prepareForEntryAnimation];
    self.contentContainerView.alpha = 0;
}

- (void)cancelEntryAnimation {
    [super cancelEntryAnimation];
    self.contentContainerView.alpha = 1;
}

- (void)performEntryAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    [super performEntryAnimationWithDuration:duration delay:delay];
    CGFloat alpha = [self alphaWithRatioFromCenter:self.cachedRatioFromCenter];
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                       [self adjustContentsWithRatio:self.cachedRatioFromCenter];
                       self.contentContainerView.alpha = alpha;
                     }
                     completion:NULL];
}

- (void)adjustContentsWithRatio:(CGFloat)ratioFromCenter {
    CGFloat const minContainerViewScale = 0.9;
    CGFloat const maxContainerViewTop = 10.f;
    CGFloat const minContainerViewTop = 0;
    CGFloat const playButtonDiameter = 48.f;
    CGFloat const playButtonMargin = 8.f;
    CGFloat base = maxContainerViewTop * ratioFromCenter * -1;
    CGFloat parallaxVerticalOffset = MAX(MIN(maxContainerViewTop, base), minContainerViewTop);
    CGFloat width = CGRectGetWidth([self containerFrame]);
    CGFloat scaleDiff = 1 - minContainerViewScale;
    CGFloat ratio = 1 - fabs(ratioFromCenter);
    CGFloat scale = ratioFromCenter < 0 ? MIN(1, (scaleDiff * ratio * 4) + minContainerViewScale) : 1;

    CGFloat scaleOffset = nearbyintf(-(width - (width * scale)) / 2);
    CGAffineTransform scaling = CGAffineTransformIdentity;
    CGFloat alpha = 1.0f;
    if (scale < 1) {
        scaling = CGAffineTransformMakeScale(scale, scale);
        alpha = [self alphaWithRatioFromCenter:ratioFromCenter];
    }
    alpha = [self isWaitingForAnimation] ? 0 : alpha;
    CGAffineTransform transform = CGAffineTransformTranslate(scaling, scaleOffset / 2, 0);
    transform = CGAffineTransformTranslate(transform, 0, parallaxVerticalOffset);
    self.contentContainerView.alpha = alpha;
    self.contentContainerView.transform = scaling;
    self.contentContainerView.frame = CGRectApplyAffineTransform([self containerFrame], transform);
    CGFloat playDiameter = playButtonDiameter * scale;
    CGFloat playMargin = playButtonMargin * scale;
    self.playButton.alpha = alpha;
    self.playButton.frame
        = CGRectMake(CGRectGetMaxX(self.contentContainerView.frame) - playDiameter - playMargin,
                     CGRectGetMaxY(self.contentContainerView.frame) - playDiameter / 2, playDiameter, playDiameter);
}

- (CGFloat)alphaWithRatioFromCenter:(CGFloat)ratioFromCenter {
    CGFloat ratio = 1 - fabs(ratioFromCenter);
    return MIN(1, ABS(ratio * 4));
}

- (void)layoutContainerViews {
    CGFloat const iconImageLeft = 4.f;
    CGFloat const iconImageTop = 4.f;
    CGFloat const iconImageDiameter = 40.f;
    CGFloat const timeLabelRight = 12.f;
    CGFloat const timeLabelTop = 17.f;
    CGFloat const messageLabelLeft = 52.f;
    CGFloat const messageLabelTop = 14.f;
    CGFloat const messageLabelRight = 8.f;
    CGFloat const messageLabelHeightOffset = 26.f;
    CGFloat const timeLabelMaxWidth = 40.f;
    CGFloat const timeLabelMaxHeight = 24.f;

    CGRect containerFrame = [self containerFrame];
    CGRect eventImageFrame = CGRectMake(iconImageLeft, iconImageTop, iconImageDiameter, iconImageDiameter);
    self.eventTypeImageView.frame = eventImageFrame;

    CGSize timeLabelSize = [self.eventTimeLabel sizeThatFits:CGSizeMake(timeLabelMaxWidth, timeLabelMaxHeight)];
    CGFloat eventTimeLeft = CGRectGetWidth(containerFrame) - (timeLabelSize.width + timeLabelRight);
    CGRect eventTimeLabelFrame = CGRectMake(eventTimeLeft, timeLabelTop, timeLabelSize.width, timeLabelSize.height);
    self.eventTimeLabel.frame = eventTimeLabelFrame;

    CGFloat containerWidth = CGRectGetWidth(containerFrame);
    CGFloat messageWidth = containerWidth - messageLabelLeft - CGRectGetWidth(eventTimeLabelFrame) - messageLabelRight
                           - timeLabelRight;
    CGRect eventMesageLabelFrame = CGRectMake(messageLabelLeft, messageLabelTop, messageWidth,
                                              CGRectGetHeight(containerFrame) - messageLabelHeightOffset);
    self.eventMessageLabel.frame = eventMesageLabelFrame;
}

- (CGRect)containerFrame {
    CGFloat const containerViewLeft = 8.f;
    CGFloat const containerViewSoundOffset = 24.f;
    CGSize size = [self.contentContainerView intrinsicContentSize];
    if ([self isDisplayingAudioViews]) {
        size.height+= containerViewSoundOffset;
    }
    return CGRectMake(containerViewLeft, 0, size.width, size.height);
}

- (void)setSelected:(BOOL)selected {
    [[self contentContainerView] setHighlighted:selected];
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [[self contentContainerView] setHighlighted:highlighted];
    [super setHighlighted:highlighted];
}

@end
