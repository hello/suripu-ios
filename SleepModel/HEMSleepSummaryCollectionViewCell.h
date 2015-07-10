
#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>

@class HEMSleepScoreGraphView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UIButton* summaryButton;
@property (weak, nonatomic) IBOutlet UIView* messageChevronView;

- (void)setScore:(NSInteger)score condition:(SENCondition)condition animated:(BOOL)animated;
- (void)setLoading:(BOOL)loading;
@end
