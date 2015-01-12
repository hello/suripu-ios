
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMBirthdatePickerViewController;

@protocol HEMBirthdatePickerDelegate <NSObject>

- (void)didSelectMonth:(NSInteger)month
                   day:(NSInteger)day
                  year:(NSInteger)year
                  from:(HEMBirthdatePickerViewController*)controller;
- (void)didCancelBirthdatePicker:(HEMBirthdatePickerViewController*)controller;

@end

@interface HEMBirthdatePickerViewController : HEMOnboardingController

@property (nonatomic, assign) id <HEMBirthdatePickerDelegate> delegate;
@property (nonatomic, assign) NSInteger initialMonth;
@property (nonatomic, assign) NSInteger initialDay;
@property (nonatomic, assign) NSInteger initialYear;

@end
