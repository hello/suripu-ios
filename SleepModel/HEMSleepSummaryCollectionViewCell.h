
#import <UIKit/UIKit.h>

@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;

- (void)setSleepScore:(NSUInteger)sleepScore;
@end
