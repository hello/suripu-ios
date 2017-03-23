
#import <AttributedMarkdown/markdown_peg.h>
#import "Sense-Swift.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMTimelineMessageContainerView.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMMarkdown.h"
#import "HEMStyle.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *borderView;
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

+ (NSDictionary*)summaryTextAttributes {
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    UIColor* boldColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextHighlightedColor];
    UIColor* regColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    style.alignment = NSTextAlignmentCenter;
    return @{@(STRONG) : @{ NSFontAttributeName : font,
                            NSForegroundColorAttributeName : boldColor,
                            NSParagraphStyleAttributeName : style},
             @(PLAIN) : @{ NSFontAttributeName : font,
                           NSForegroundColorAttributeName : regColor,
                           NSParagraphStyleAttributeName : style},
             @(PARA) : @{ NSFontAttributeName : font,
                          NSForegroundColorAttributeName : regColor,
                          NSParagraphStyleAttributeName : style}};
}

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
    self.summaryLabel.text = NSLocalizedString(@"timeline.summary", nil);
    self.sleepScoreTextLabel.attributedText = self.sleepScoreLabelText;
    [self applyStyle];
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
    NSDictionary *attributes = [[self class] summaryTextAttributes];
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

- (void)applyStyle {
    self.backgroundColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    self.summaryLabel.textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyPrimaryButtonTextColor];
    self.summaryLabel.font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyPrimaryButtonTextFont];
    self.sleepScoreTextLabel.textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    self.sleepScoreTextLabel.font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    self.borderView.backgroundColor = self.backgroundColor;
}

@end
