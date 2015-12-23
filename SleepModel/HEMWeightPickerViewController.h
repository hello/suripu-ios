
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMWeightPickerViewController;
@class HEMAccountUpdateDelegate;

@interface HEMWeightPickerViewController : HEMOnboardingController

@property (nonatomic, assign) NSNumber* defaultWeightInGrams;
@property (nonatomic, strong) HEMAccountUpdateDelegate* delegate;

@end
