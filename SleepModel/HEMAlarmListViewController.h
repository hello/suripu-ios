
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMDeviceService;

@interface HEMAlarmListViewController : HEMBaseController

@property (nonatomic, assign) BOOL hasSubNav;
@property (nonatomic, strong) HEMDeviceService* deviceService;

- (IBAction)addNewAlarm:(id)sender;

@end
