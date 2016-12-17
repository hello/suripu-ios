
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMTimelineMessageContainerView.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMMarkdown.h"
#import "HEMStyle.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *sleepScoreTextLabel;
@property (weak, nonatomic) IBOutlet UIView *summaryContainerView;
@property (nonatomic, strong) NSAttributedString *sleepScoreLabelText;
@property (assign, nonatomic) CGFloat ogMessageContainerShadowOpacity;
@end

@implementation HEMSleepSummaryCollectionViewCell

CGFloat const HEMSleepSummaryButtonKerning = 0.5f;
CGFloat const HEMSleepSummaryTopPadding = 16.0f;
CGFloat const HEMSleepSummaryScoreGraphHeight = 153.0f; // graph + top padding + sleep score label
CGFloat const HEMSleepSummaryTextTopSpacing = 36.0f;
CGFloat const HEMSleepSummaryTextSpacing = 16.0f;
CGFloat const HEMSleepSummarySummaryHeight = 12.0f;
CGFloat const HEMSleepSummaryBottomPadding = 24.0f;
CGFloat const HEMSleepSummaryMessageHorzPadding = 24.0f;

+ (CGFloat)heightWithMessage:(NSString*)message itemWidth:(CGFloat)width {
    NSDictionary *attributes = [HEMMarkdown attributesForTimelineMessageText];
    NSAttributedString *attributedMessage = [markdown_to_attr_string(message, 0, attributes) trim];
    CGFloat maxWidth = width - (HEMSleepSummaryMessageHorzPadding * 2);
    CGFloat textHeight = [attributedMessage sizeWithWidth:maxWidth].height;
    return HEMSleepSummaryScoreGraphHeight
        + HEMSleepSummaryTextTopSpacing
        + textHeight
        + HEMSleepSummaryTextSpacing
        + HEMSleepSummarySummaryHeight
        + HEMSleepSummaryBottomPadding;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSDictionary *attributes = @{ NSKernAttributeName : @1 };
        _sleepScoreLabelText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"sleep-history.score", nil)
                                                               attributes:attributes];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.summaryLabel.font = [UIFont bodyBold];
    self.summaryLabel.textColor = [UIColor grey4];
    self.summaryLabel.text = NSLocalizedString(@"timeline.summary", nil);
    self.sleepScoreTextLabel.attributedText = self.sleepScoreLabelText;
    self.sleepScoreTextLabel.isAccessibilityElement = NO;
    self.messageLabel.isAccessibilityElement = NO;
    self.messageContainerView.isAccessibilityElement = YES;
    self.messageContainerView.accessibilityLabel = NSLocalizedString(@"timeline.accessibility-label.breakdown", nil);
    self.messageContainerView.accessibilityHint = NSLocalizedString(@"timeline.accessibility-hint.breakdown", nil);
    self.messageContainerView.accessibilityTraits = UIAccessibilityTraitButton;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.sleepScoreGraphView setLoading:NO];
}

- (NSInteger)accessibilityElementCount {
    return 2;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    if (index == 0)
        return self.sleepScoreGraphView;
    return self.messageContainerView;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    if ([element isEqual:self.sleepScoreGraphView])
        return 0;
    else if ([element isEqual:self.messageContainerView])
        return 1;
    return NSNotFound;
}

- (void)setLoading:(BOOL)loading {
    [self.sleepScoreGraphView setLoading:loading];
}

- (void)setScore:(NSInteger)sleepScore
         message:(NSString *)message
       condition:(SENCondition)condition
        animated:(BOOL)animated {
    CGFloat const fullScoreDelay = 0.05f;
    BOOL scoreIsEmpty = sleepScore == 0;
    NSDictionary *attributes = [HEMMarkdown attributesForTimelineMessageText];
    NSAttributedString *attributedMessage = [markdown_to_attr_string(message, 0, attributes) trim];
    self.messageLabel.attributedText = attributedMessage;
    self.sleepScoreTextLabel.hidden = scoreIsEmpty;
    [self.sleepScoreGraphView setScore:sleepScore condition:condition animated:animated];
    if (self.messageContainerView.alpha != 1 && ![self.sleepScoreGraphView isLoading]) {
        [UIView animateWithDuration:0.25f
                              delay:scoreIsEmpty ? 0 : fullScoreDelay
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                           self.messageContainerView.alpha = 1;
                         }
                         completion:NULL];
    }
   self.messageContainerView.accessibilityValue = [attributedMessage string];
}

- (void)setSummaryViewsVisible:(BOOL)visible {
    CGFloat summaryAlpha = visible ? 1.f : 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                       self.summaryContainerView.alpha = summaryAlpha;
                     }];
}

- (void)setTintColor:(UIColor *)tintColor onButton:(UIButton *)button {
    NSDictionary *attributes =
        @{ NSKernAttributeName : @(HEMSleepSummaryButtonKerning),
           NSForegroundColorAttributeName : tintColor };
    NSAttributedString *text =
        [[NSAttributedString alloc] initWithString:[button titleForState:UIControlStateNormal] attributes:attributes];
    [button setAttributedTitle:text forState:UIControlStateNormal];
    [button setTintColor:tintColor];
}

@end
