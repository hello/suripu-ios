
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class SENAlarm;
@class HEMAlarmViewController;
@class HEMAlarmService;
@class HEMDeviceService;
@class HEMExpansionService;

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
@property (nonatomic, strong) HEMDeviceService* deviceService;
@property (nonatomic, strong) HEMExpansionService* expansionService;
@property (nonatomic, weak)   id<HEMAlarmControllerDelegate> delegate;

@end
