
#import <UIKit/UIKit.h>

@interface HEMSensorDataHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *particulateLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
