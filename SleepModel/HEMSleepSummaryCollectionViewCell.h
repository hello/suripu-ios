
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
@end
