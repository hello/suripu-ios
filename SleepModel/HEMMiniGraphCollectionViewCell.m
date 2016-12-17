
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMMiniGraphLoadingStopDuration = 0.75f;

@interface HEMMiniGraphCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityView;
@end

@implementation HEMMiniGraphCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureDefaults];
}

- (void)configureDefaults {
    self.leftBorderView.alpha = 1.0f;
    self.rightBorderView.alpha = 1.0f;
    self.leftBorderView.hidden = YES;
    self.rightBorderView.hidden = YES;
    self.sleepScoreView.alpha = 0.0f;
    self.graphView.alpha = 0.0f;
    
    [self.activityView stop];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self configureDefaults];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    CGFloat alpha = layoutAttributes.alpha < 0.5 ? 0 : 1;
    self.leftBorderView.alpha = alpha;
    self.rightBorderView.alpha = alpha;
    
    CGFloat dataAlpha = [self.activityView isAnimating] ? 0.0f : layoutAttributes.alpha;
    self.sleepScoreView.alpha = dataAlpha;
    self.graphView.alpha = dataAlpha;
}

- (void)showLoadingActivity:(BOOL)show {
    if (show && ![self.activityView isAnimating]) {
        self.sleepScoreView.alpha = 0.0f;
        self.graphView.alpha = 0.0f;
        [self.activityView start];
    } else if (!show && [self.activityView isAnimating]) {
        [UIView animateWithDuration:HEMMiniGraphLoadingStopDuration animations:^{
            self.activityView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.activityView stop];
            self.activityView.alpha = 1.0f;
            [UIView animateWithDuration:HEMMiniGraphLoadingStopDuration
                             animations:^{
                                 self.sleepScoreView.alpha = 1.0f;
                                 self.graphView.alpha = 1.0f;
                             } completion:nil];
        }];
    }
}

@end
