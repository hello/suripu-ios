
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@end

@implementation HEMSleepSummaryCollectionViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated
{
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

@end
