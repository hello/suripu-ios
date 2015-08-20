
#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>

@class HEMSleepScoreGraphView;
@class HEMTimelineMessageContainerView;

@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UIView* messageChevronView;
@property (weak, nonatomic) IBOutlet HEMTimelineMessageContainerView *messageContainerView;

- (void)setScore:(NSInteger)score condition:(SENCondition)condition animated:(BOOL)animated;
- (void)setLoading:(BOOL)loading;
@end
