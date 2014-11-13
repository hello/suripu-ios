
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMGenderPickerViewController;

@protocol HEMGenderPickerDelegate <NSObject>

- (void)didSelectGender:(SENAccountGender)gender
                   from:(HEMGenderPickerViewController*)controller;
- (void)didCancelGenderFrom:(HEMGenderPickerViewController*)controller;

@end

@interface HEMGenderPickerViewController : HEMBaseController

@property (nonatomic, assign) SENAccountGender defaultGender;
@property (nonatomic, weak) id<HEMGenderPickerDelegate> delegate;

@end
