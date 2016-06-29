
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMDeviceService;
@class HEMSubNavigationView;

@interface HEMAlarmListViewController : HEMBaseController

@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, strong) HEMDeviceService* deviceService;

- (void)addNewAlarmFromShortcut;

@end
