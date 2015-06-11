
#import <SpinKit/RTSpinKitView.h>
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMSleepSummaryPointerGradientView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *sleepScoreTextLabel;
@property (weak, nonatomic) IBOutlet UIView *summaryContainerView;
@property (nonatomic, strong) NSAttributedString *sleepScoreLabelText;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation HEMSleepSummaryCollectionViewCell

CGFloat const HEMSleepSummaryButtonKerning = 0.5f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        NSDictionary *attributes = @{ NSKernAttributeName : @1 };
        _sleepScoreLabelText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"sleep-history.score", nil)
                                                               attributes:attributes];
    }
    return self;
}

- (void)awakeFromNib {
    [self configureSpinner];
    [self configureGradientViews];
    self.sleepScoreTextLabel.attributedText = self.sleepScoreLabelText;
}

- (void)configureSpinner {
    self.spinnerView.color = [UIColor colorWithWhite:0.1 alpha:0.2];
    self.spinnerView.spinnerSize = CGRectGetWidth(self.spinnerView.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
}

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated {
    BOOL scoreIsEmpty = sleepScore == 0;
    self.sleepScoreTextLabel.hidden = scoreIsEmpty;
    if (!scoreIsEmpty)
        [self.spinnerView stopAnimating];
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

- (void)setSummaryViewsVisible:(BOOL)visible {
    CGFloat summaryAlpha = visible ? 1.f : 0;
    [UIView animateWithDuration:0.25 animations:^{ self.summaryContainerView.alpha = summaryAlpha; }];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

#pragma mark - Gradient background

- (void)configureGradientViews {
    NSArray *topColors = @[ (id)[UIColor whiteColor].CGColor, (id)[UIColor colorWithWhite:0.96f alpha:1.f].CGColor ];

    CAGradientLayer *topLayer = [CAGradientLayer layer];
    topLayer.colors = topColors;
    topLayer.frame = self.bounds;
    topLayer.locations = @[ @(0.5), @1 ];
    topLayer.startPoint = CGPointZero;
    topLayer.endPoint = CGPointMake(0, 1);
    self.gradientLayer = topLayer;
    [self.layer insertSublayer:topLayer atIndex:0];
}

@end
