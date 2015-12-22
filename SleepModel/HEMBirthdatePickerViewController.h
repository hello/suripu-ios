
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMBirthdatePickerViewController;
@class HEMAccountUpdateDelegate;

@interface HEMBirthdatePickerViewController : HEMOnboardingController

@property (nonatomic, strong) HEMAccountUpdateDelegate* updateDelegate;
@property (nonatomic, assign) NSInteger initialMonth;
@property (nonatomic, assign) NSInteger initialDay;
@property (nonatomic, assign) NSInteger initialYear;

@end
