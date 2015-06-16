
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@class RTSpinKitView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UIButton* summaryButton;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
@end
