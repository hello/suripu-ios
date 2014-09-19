
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMWeightPickerViewController;

@protocol HEMWeightPickerDelegate <NSObject>

- (void)didSelectWeightInKgs:(CGFloat)weightKgs
                        from:(HEMWeightPickerViewController*)controller;

@end

@interface HEMWeightPickerViewController : HEMBaseController

@property (nonatomic, assign) NSInteger defaultWeightLbs;
@property (nonatomic, weak) id<HEMWeightPickerDelegate> delegate;

@end
