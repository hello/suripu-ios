
#import <SpinKit/RTSpinKitView.h>
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *presleepButton;
@property (weak, nonatomic) IBOutlet UIButton *sleepSummaryButton;
@property (weak, nonatomic) IBOutlet UILabel *sleepScoreTextLabel;
@property (weak, nonatomic) IBOutlet UIView *presleepContainerView;
@property (nonatomic, strong) NSAttributedString* sleepScoreLabelText;
@end

@implementation HEMSleepSummaryCollectionViewCell

static CGFloat const HEMSleepSummaryButtonEdgeInset = 8.f;
static CGFloat const HEMSleepSummaryButtonKerning = 0.5f;

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        NSDictionary* attributes = @{NSKernAttributeName:@1};
        _sleepScoreLabelText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"sleep-history.score", nil)
                                                               attributes:attributes];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureSpinner];
    [self configureButtons];
    [self showSleepSummary:nil];
}

- (void)configureButtons
{
    UIImage* presleepImage = [self.presleepButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* summaryImage = [self.sleepSummaryButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, HEMSleepSummaryButtonEdgeInset);
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsMake(0, HEMSleepSummaryButtonEdgeInset, 0, 0);
    self.presleepButton.imageEdgeInsets = imageEdgeInsets;
    self.presleepButton.titleEdgeInsets = titleEdgeInsets;
    [self.presleepButton setImage:presleepImage forState:UIControlStateNormal];
    self.sleepSummaryButton.imageEdgeInsets = imageEdgeInsets;
    self.sleepSummaryButton.titleEdgeInsets = titleEdgeInsets;
    [self.sleepSummaryButton setImage:summaryImage forState:UIControlStateNormal];
    self.sleepScoreTextLabel.attributedText = self.sleepScoreLabelText;
}

- (void)configureSpinner
{
    self.spinnerView.color = [UIColor colorWithWhite:0.1 alpha:0.2];
    self.spinnerView.spinnerSize = CGRectGetWidth(self.spinnerView.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
}

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated
{
    BOOL scoreIsEmpty = sleepScore == 0;
    self.sleepScoreTextLabel.hidden = scoreIsEmpty;
    self.presleepButton.hidden = scoreIsEmpty;
    self.sleepSummaryButton.hidden = scoreIsEmpty;
    if (!scoreIsEmpty)
        [self.spinnerView stopAnimating];
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

- (IBAction)showSleepSummary:(id)sender
{
    UIColor* tintColor = [HelloStyleKit tintColor];
    UIColor* inactiveColor = [HelloStyleKit barButtonDisabledColor];
    [self setTintColor:tintColor onButton:self.sleepSummaryButton];
    [self setTintColor:inactiveColor onButton:self.presleepButton];
    [self setSummaryViewsVisible:YES];
}

- (IBAction)showPresleepSummary:(id)sender
{
    UIColor* tintColor = [HelloStyleKit tintColor];
    UIColor* inactiveColor = [HelloStyleKit barButtonDisabledColor];
    [self setTintColor:tintColor onButton:self.presleepButton];
    [self setTintColor:inactiveColor onButton:self.sleepSummaryButton];
    [self setSummaryViewsVisible:NO];
}

- (void)setSummaryViewsVisible:(BOOL)visible
{
    CGFloat summaryAlpha = visible ? 1.f : 0;
    CGFloat presleepAlpha = visible ? 0 : 1.f;
    [UIView animateWithDuration:0.25 animations:^{
        self.messageLabel.alpha = summaryAlpha;
        self.spinnerView.alpha = summaryAlpha;
        self.sleepScoreGraphView.alpha = summaryAlpha;
        self.sleepScoreTextLabel.alpha = summaryAlpha;
        self.presleepContainerView.alpha = presleepAlpha;
    }];
}

- (void)setTintColor:(UIColor *)tintColor onButton:(UIButton*)button
{
    NSDictionary* attributes = @{NSKernAttributeName:@(HEMSleepSummaryButtonKerning),
                                 NSForegroundColorAttributeName:tintColor};
    NSAttributedString* text = [[NSAttributedString alloc] initWithString:[button titleForState:UIControlStateNormal]
                                                               attributes:attributes];
    [button setAttributedTitle:text forState:UIControlStateNormal];
    [button setTintColor:tintColor];
}

@end
