
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMGenderPickerViewController;
@class HEMAccountUpdateDelegate;
@class SENAccount;

@interface HEMGenderPickerViewController : HEMOnboardingController

@property (nonatomic, strong) SENAccount* account; // account to update
@property (nonatomic, assign) SENAccountGender defaultGender;
@property (nonatomic, strong) HEMAccountUpdateDelegate* delegate;

@end
