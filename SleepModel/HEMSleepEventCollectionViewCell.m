
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepEventCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMTimelineLayoutAttributes.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"
#import "HEMEventBubbleView.h"

@interface HEMSleepEventCollectionViewCell ()

@end

@implementation HEMSleepEventCollectionViewCell

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text {
    return [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForEventMessageText]) trim];
}

- (void)applyLayoutAttributes:(HEMTimelineLayoutAttributes *)layoutAttributes {
    [self layoutContainerViewWithAttributes:layoutAttributes];
    [self animateContentsWithAttributes:layoutAttributes];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentContainerView setMessageText:nil timeText:nil];
}

- (void)animateContentsWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const minContainerViewScale = 0.9;
    CGFloat scaleDiff = 1 - minContainerViewScale;
    CGFloat ratio = 1 - fabs(attributes.ratioFromCenter);
    CGFloat scale = attributes.ratioFromCenter < 0 ? MIN(1, (scaleDiff * ratio * 4) + minContainerViewScale) : 1;
    CGFloat alphaRatio = attributes.ratioFromCenter < 0 ? MIN(1, ratio * 4) : 1;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    self.contentContainerView.alpha = alphaRatio;
    if (!CGAffineTransformEqualToTransform(self.contentContainerView.transform, scaleTransform)) {
        self.contentContainerView.transform = scaleTransform;
    }
}

- (void)layoutContainerViewWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const containerViewLeft = 10.f;
    CGFloat const maxContainerViewTop = 10.f;
    CGFloat const minContainerViewTop = 0.f;
    CGFloat const iconImageLeft = 4.f;
    CGFloat const iconImageTop = 4.f;
    CGFloat const iconImageDiameter = 40.f;
    CGFloat const timeLabelRight = 8.f;
    CGFloat const timeLabelLeft = 10.f;
    CGFloat const timeLabelTop = 16.f;
    CGFloat const messageLabelLeft = 52.f;
    CGFloat const messageLabelTop = 13.f;
    CGFloat const messageLabelRight = 8.f;
    CGFloat const messageLabelHeightOffset = 26.f;
    CGFloat const timeLabelMaxWidth = 40.f;
    CGFloat const timeLabelMaxHeight = 24.f;
    CGFloat base;
    if (attributes != nil) {
        base = maxContainerViewTop * attributes.ratioFromCenter * -1;
    } else {
        base = CGRectGetMinY(self.contentContainerView.frame);
    }
    CGFloat top = floorf(MAX(MIN(maxContainerViewTop, base), minContainerViewTop));
    CGSize size = [self.contentContainerView intrinsicContentSize];
    CGRect containerFrame = CGRectMake(containerViewLeft, top, size.width, size.height);
    self.contentContainerView.frame = containerFrame;

    CGRect eventImageFrame = CGRectMake(iconImageLeft, iconImageTop, iconImageDiameter, iconImageDiameter);
    self.eventTypeImageView.frame = eventImageFrame;

    CGSize timeLabelSize = [self.eventTimeLabel sizeThatFits:CGSizeMake(timeLabelMaxWidth, timeLabelMaxHeight)];
    CGFloat left = CGRectGetWidth(containerFrame) - timeLabelSize.width - timeLabelRight - timeLabelLeft;
    CGRect eventTimeLabelFrame = CGRectMake(left, timeLabelTop, timeLabelSize.width, timeLabelSize.height);
    self.eventTimeLabel.frame = eventTimeLabelFrame;

    CGFloat containerWidth = CGRectGetWidth(containerFrame);
    CGFloat messageWidth = containerWidth - messageLabelLeft - CGRectGetWidth(eventTimeLabelFrame) - messageLabelRight
                           - timeLabelRight;
    CGRect eventMesageLabelFrame = CGRectMake(messageLabelLeft, messageLabelTop, messageWidth,
                                              CGRectGetHeight(containerFrame) - messageLabelHeightOffset);
    self.eventMessageLabel.frame = eventMesageLabelFrame;
}

- (void)setNeedsLayout {
    [self setNeedsDisplay];
    [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutContainerViewWithAttributes:nil];
}

@end
