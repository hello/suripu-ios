
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"

@interface HEMMiniGraphCollectionViewCell ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borderViews;
@end

@implementation HEMMiniGraphCollectionViewCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    CGFloat alpha = layoutAttributes.alpha < 0.5 ? 0 : 1;
    for (UIView* borderView in self.borderViews) {
        borderView.alpha = alpha;
    }
}
@end
