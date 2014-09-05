
#import <UIKit/UIKit.h>

@class JBLineChartView;

@interface HEMAggregateGraphCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet JBLineChartView* chartView;
@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@end
