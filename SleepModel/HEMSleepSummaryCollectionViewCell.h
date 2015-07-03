
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UIButton* summaryButton;
@property (weak, nonatomic) IBOutlet UIView* messageChevronView;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
- (void)setLoading:(BOOL)loading;
@end
