
#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>

@class HEMSleepScoreGraphView;
@class HEMTimelineMessageContainerView;

@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView *sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UIView *messageChevronView;
@property (weak, nonatomic) IBOutlet HEMTimelineMessageContainerView *messageContainerView;

+ (CGFloat)heightWithMessage:(NSString*)message itemWidth:(CGFloat)width;
- (void)setScore:(NSInteger)score message:(NSString *)message condition:(SENCondition)condition animated:(BOOL)animated;
- (void)setLoading:(BOOL)loading;
@end
