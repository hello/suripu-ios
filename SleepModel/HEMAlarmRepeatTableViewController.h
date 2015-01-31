
#import <UIKit/UIKit.h>

@class HEMAlarmCache;
@class SENAlarm;

@interface HEMAlarmRepeatTableViewController : UIViewController

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) SENAlarm* alarm;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@end
