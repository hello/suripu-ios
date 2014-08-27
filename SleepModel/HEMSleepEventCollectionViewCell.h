
#import <UIKit/UIKit.h>
#import "HEMLinedCollectionViewCell.h"

@interface HEMSleepEventCollectionViewCell : HEMLinedCollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton* eventTypeButton;
@property (nonatomic, getter=isExpanded) BOOL expanded;
@property (weak, nonatomic) IBOutlet UILabel* eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventMessageLabel;
@end
