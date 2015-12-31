
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class SENAlarm;
@class HEMAlarmViewController;

@protocol HEMAlarmControllerDelegate <NSObject>

@required
- (void)didCancelAlarmFrom:(HEMAlarmViewController*)alarmVC;
- (void)didSaveAlarm:(SENAlarm*)alarm from:(HEMAlarmViewController*)alarmVC;

@end

@interface HEMAlarmViewController : HEMBaseController

@property (nonatomic, strong) SENAlarm* alarm;
@property (nonatomic, weak)   id<HEMAlarmControllerDelegate> delegate;

@end
