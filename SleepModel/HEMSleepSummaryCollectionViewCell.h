
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@class RTSpinKitView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet RTSpinKitView *spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *drawerButton;
@property (weak, nonatomic) IBOutlet UIButton* dateButton;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topItemsVerticalConstraint;

@property (weak, nonatomic) IBOutlet UILabel *presleepInsightLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *presleepImageView1;
@property (weak, nonatomic) IBOutlet UILabel *presleepInsightLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *presleepImageView2;
@property (weak, nonatomic) IBOutlet UILabel *presleepInsightLabel3;
@property (weak, nonatomic) IBOutlet UIImageView *presleepImageView3;
@property (weak, nonatomic) IBOutlet UILabel *presleepInsightLabel4;
@property (weak, nonatomic) IBOutlet UIImageView *presleepImageView4;
@property (weak, nonatomic) IBOutlet UILabel *presleepInsightLabel5;
@property (weak, nonatomic) IBOutlet UIImageView *presleepImageView5;


- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
@end
