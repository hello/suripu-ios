
#import <UIKit/UIKit.h>

@class HEMMiniSleepHistoryView;
@class HEMMiniSleepScoreGraphView;

@interface HEMMiniGraphCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* dayOfWeekLabel;
@property (weak, nonatomic) IBOutlet UILabel* dayLabel;
@property (weak, nonatomic) IBOutlet UIView *leftBorderView;
@property (weak, nonatomic) IBOutlet UIView *rightBorderView;
@property (weak, nonatomic) IBOutlet HEMMiniSleepScoreGraphView* sleepScoreView;
@property (weak, nonatomic) IBOutlet HEMMiniSleepHistoryView* graphView;

@end
