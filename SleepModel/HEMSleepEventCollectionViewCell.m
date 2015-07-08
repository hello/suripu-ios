
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepEventCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMTimelineLayoutAttributes.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"
#import "HEMEventBubbleView.h"

@interface HEMSleepEventCollectionViewCell ()
@property (nonatomic) CGFloat cachedRatioFromCenter;
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
}

- (void)applyLayoutAttributes:(HEMTimelineLayoutAttributes *)layoutAttributes {
    CGFloat ratio = layoutAttributes.ratioFromCenter;
    self.cachedRatioFromCenter = ratio;
    [self adjustContentsWithRatio:ratio];
}

- (void)prepareForReuse {
    [super prepareForReuse];
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
    CGFloat cachedAlpha = [self alphaWithRatioFromCenter:self.cachedRatioFromCenter];
    CGFloat alpha = cachedAlpha > 0 ? cachedAlpha : 1.f;
    [UIView animateWithDuration:duration
                          delay:delay
                        options:0
                     animations:^{
                       self.contentContainerView.alpha = alpha;
                     }
                     completion:NULL];
}

- (void)adjustContentsWithRatio:(CGFloat)ratioFromCenter {
    CGFloat const minContainerViewScale = 0.9;
    CGFloat const maxContainerViewTop = 10.f;
    CGFloat const minContainerViewTop = 0;
    CGFloat base = maxContainerViewTop * ratioFromCenter * -1;
    CGFloat parallaxVerticalOffset = MAX(MIN(maxContainerViewTop, base), minContainerViewTop);
    CGFloat width = CGRectGetWidth([self containerFrame]);
    CGFloat scaleDiff = 1 - minContainerViewScale;
    CGFloat ratio = 1 - fabs(ratioFromCenter);
    CGFloat scale = ratioFromCenter < 0 ? MIN(1, (scaleDiff * ratio * 4) + minContainerViewScale) : 1;
    CGFloat scaleOffset = nearbyintf(-(width - (width * scale)) / 2);
    CGAffineTransform scaling = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform transform = CGAffineTransformTranslate(scaling, scaleOffset / 2, 0);
    transform = CGAffineTransformTranslate(transform, 0, parallaxVerticalOffset);
    self.contentContainerView.alpha =
        [self isWaitingForAnimation] ? 0 : [self alphaWithRatioFromCenter:ratioFromCenter];
    self.contentContainerView.transform = scale < 1 ? scaling : CGAffineTransformIdentity;
    self.contentContainerView.frame = CGRectApplyAffineTransform([self containerFrame], transform);
}

- (CGFloat)alphaWithRatioFromCenter:(CGFloat)ratioFromCenter {
    CGFloat ratio = 1 - fabs(ratioFromCenter);
    return MIN(1, ABS(ratio * 3));
}

- (void)layoutContainerViews {
    CGFloat const iconImageLeft = 4.f;
    CGFloat const iconImageTop = 4.f;
    CGFloat const iconImageDiameter = 40.f;
    CGFloat const timeLabelRight = 12.f;
    CGFloat const timeLabelTop = 18.f;
    CGFloat const messageLabelLeft = 52.f;
    CGFloat const messageLabelTop = 13.f;
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
    CGFloat messageWidth = containerWidth - messageLabelLeft - CGRectGetWidth(eventTimeLabelFrame) - messageLabelRight - timeLabelRight;
    CGRect eventMesageLabelFrame = CGRectMake(messageLabelLeft, messageLabelTop, messageWidth,
                                              CGRectGetHeight(containerFrame) - messageLabelHeightOffset);
    self.eventMessageLabel.frame = eventMesageLabelFrame;
}

- (CGRect)containerFrame {
    CGFloat const containerViewLeft = 10.f;
    CGSize size = [self.contentContainerView intrinsicContentSize];
    return CGRectMake(containerViewLeft, 0, size.width, size.height);
}

@end
