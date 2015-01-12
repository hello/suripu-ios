
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMGenderPickerViewController;

@protocol HEMGenderPickerDelegate <NSObject>

- (void)didSelectGender:(SENAccountGender)gender
                   from:(HEMGenderPickerViewController*)controller;
- (void)didCancelGenderFrom:(HEMGenderPickerViewController*)controller;

@end

@interface HEMGenderPickerViewController : HEMOnboardingController

@property (nonatomic, assign) SENAccountGender defaultGender;
@property (nonatomic, weak) id<HEMGenderPickerDelegate> delegate;

@end
