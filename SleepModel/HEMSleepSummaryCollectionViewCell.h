
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *drawerButton;
@property (weak, nonatomic) IBOutlet UIButton* dateButton;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topItemsVerticalConstraint;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
@end
