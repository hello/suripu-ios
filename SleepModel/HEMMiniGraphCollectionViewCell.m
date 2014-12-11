
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"

@interface HEMMiniGraphCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borderViews;
@end

@implementation HEMMiniGraphCollectionViewCell

static CGFloat const HEMMinimumScoreWidth = 64.f;
static CGFloat const HEMMaximumScoreInset = 40.f;

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    CGFloat alpha = layoutAttributes.alpha < 0.5 ? 0 : 1;
    for (UIView* borderView in self.borderViews) {
        borderView.alpha = alpha;
    }
    [self updateScoreViewWidthWithAlpha:layoutAttributes.alpha];
}

- (void)updateScoreViewWidthWithAlpha:(CGFloat)alpha {
    CGFloat max = CGRectGetWidth(self.bounds) - HEMMaximumScoreInset;
    CGFloat min = HEMMinimumScoreWidth;
    CGFloat proportionalSize = MIN(MIN(alpha, 1)/0.4 * min, max);
    CGFloat width = alpha < 0.5 ? MAX(min, proportionalSize) : proportionalSize;
    if (self.heightConstraint.constant != width) {
        self.heightConstraint.constant = width;
        self.widthConstraint.constant = width;
        [self.sleepScoreView layoutIfNeeded];
        [self.sleepScoreView setNeedsDisplay];
    }
}

@end
