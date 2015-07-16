
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"

@interface HEMMiniGraphCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@end

@implementation HEMMiniGraphCollectionViewCell

- (void)awakeFromNib {
    [self configureBorderDefaults];
}

- (void)configureBorderDefaults {
    self.leftBorderView.alpha = 1.0f;
    self.rightBorderView.alpha = 1.0f;
    self.leftBorderView.hidden = YES;
    self.rightBorderView.hidden = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self configureBorderDefaults];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    CGFloat alpha = layoutAttributes.alpha < 0.5 ? 0 : 1;
    self.leftBorderView.alpha = alpha;
    self.rightBorderView.alpha = alpha;
}

@end
