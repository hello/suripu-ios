
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton* eventTypeButton;
@property (weak, nonatomic) IBOutlet UILabel* eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventTimeLabel;

- (void)showLargeButton:(BOOL)buttonIsLarge;
@end
