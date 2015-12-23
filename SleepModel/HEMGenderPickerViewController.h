
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMGenderPickerViewController;
@class HEMAccountUpdateDelegate;

@interface HEMGenderPickerViewController : HEMOnboardingController

@property (nonatomic, assign) SENAccountGender defaultGender;
@property (nonatomic, strong) HEMAccountUpdateDelegate* delegate;

@end
