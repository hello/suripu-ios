
#import <UIKit/UIKit.h>

extern CGFloat const HEPDeviceTableViewCellHeight;

@interface HEPDeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel* signalStrengthLabel;
@end
