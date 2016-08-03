
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class SENAlarm;
@class HEMAlarmViewController;
@class HEMAlarmService;

@protocol HEMAlarmControllerDelegate <NSObject>

@required

- (void)didCancelAlarmFrom:(HEMAlarmViewController*)alarmVC;
- (void)didSaveAlarm:(SENAlarm*)alarm from:(HEMAlarmViewController*)alarmVC;

@end

@interface HEMAlarmViewController : HEMBaseController

@property (nonatomic, copy) NSString* successText;
@property (nonatomic, assign) CGFloat successDuration;
@property (nonatomic, strong) SENAlarm* alarm;
@property (nonatomic, strong) HEMAlarmService* alarmService;
@property (nonatomic, weak)   id<HEMAlarmControllerDelegate> delegate;

@end
