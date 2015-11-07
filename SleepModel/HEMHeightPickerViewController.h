
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMHeightPickerViewController;

@protocol HEMHeightPickerDelegate <NSObject>

- (void)didSelectHeightInCentimeters:(CGFloat)centimeters
                                from:(HEMHeightPickerViewController*)controller;
- (void)didCancelHeightFrom:(HEMHeightPickerViewController*)controller;

@end

@interface HEMHeightPickerViewController : HEMOnboardingController

@property (assign, nonatomic) NSNumber* heightInCm;

@property (weak, nonatomic) id<HEMHeightPickerDelegate> delegate;

@end
