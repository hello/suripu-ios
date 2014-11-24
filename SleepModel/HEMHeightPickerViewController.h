
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMHeightPickerViewController;

@protocol HEMHeightPickerDelegate <NSObject>

- (void)didSelectHeightInCentimeters:(int)centimeters
                                from:(HEMHeightPickerViewController*)controller;
- (void)didCancelHeightFrom:(HEMHeightPickerViewController*)controller;

@end

@interface HEMHeightPickerViewController : HEMBaseController

@property (assign, nonatomic) NSInteger feet;
@property (assign, nonatomic) NSInteger inches;

@property (weak, nonatomic) id<HEMHeightPickerDelegate> delegate;

@end
