
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMBirthdatePickerViewController;

@protocol HEMBirthdatePickerDelegate <NSObject>

- (void)didSelectMonth:(NSInteger)month
                   day:(NSInteger)day
                  year:(NSInteger)year
                  from:(HEMBirthdatePickerViewController*)controller;
- (void)didCancelBirthdatePicker:(HEMBirthdatePickerViewController*)controller;

@end

@interface HEMBirthdatePickerViewController : HEMBaseController

@property (nonatomic, assign) id <HEMBirthdatePickerDelegate> delegate;
@property (nonatomic, assign) NSInteger initialMonth;
@property (nonatomic, assign) NSInteger initialDay;
@property (nonatomic, assign) NSInteger initialYear;

@end
