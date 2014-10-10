
#import <UIKit/UIKit.h>

@class HEMAlarmCache;
@class SENAlarm;

@interface HEMAlarmRepeatTableViewController : UITableViewController

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) SENAlarm* alarm;
@end
