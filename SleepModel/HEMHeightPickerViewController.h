
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMHeightPickerViewController;
@class HEMAccountUpdateDelegate;

@protocol HEMHeightPickerDelegate <NSObject>

- (void)didSelectHeightInCentimeters:(CGFloat)centimeters
                                from:(HEMHeightPickerViewController*)controller;
- (void)didCancelHeightFrom:(HEMHeightPickerViewController*)controller;

@end

@interface HEMHeightPickerViewController : HEMOnboardingController

@property (assign, nonatomic) NSNumber* heightInCm;
@property (strong, nonatomic) HEMAccountUpdateDelegate* delegate;

@end
