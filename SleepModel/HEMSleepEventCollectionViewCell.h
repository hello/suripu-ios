
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton* eventTypeButton;
@property (nonatomic, getter=isExpanded) BOOL expanded;
@property (weak, nonatomic) IBOutlet UILabel* eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@end
