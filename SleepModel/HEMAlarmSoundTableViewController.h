
#import <UIKit/UIKit.h>

@class HEMAlarmCache;

@interface HEMAlarmSoundTableViewController : UIViewController

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@end
