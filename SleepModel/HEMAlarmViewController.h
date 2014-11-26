
#import <UIKit/UIKit.h>

@class SENAlarm;
@class HEMAlarmViewController;

@protocol HEMAlarmControllerDelegate <NSObject>

- (void)didCancelAlarmFrom:(HEMAlarmViewController*)alarmVC;
- (void)didSaveAlarm:(SENAlarm*)alarm from:(HEMAlarmViewController*)alarmVC;

@end

@interface HEMAlarmViewController : UITableViewController

@property (nonatomic, strong) SENAlarm* alarm;
@property (nonatomic, weak)   id<HEMAlarmControllerDelegate> delegate;

@end
