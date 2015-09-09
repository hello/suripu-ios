
#import <UIKit/UIKit.h>
#import "HEMOnboardingController.h"

@class HEMWeightPickerViewController;

@protocol HEMWeightPickerDelegate <NSObject>

- (void)didSelectWeightInGrams:(float)grams
                          from:(HEMWeightPickerViewController*)controller;
- (void)didCancelWeightFrom:(HEMWeightPickerViewController*)controller;

@end

@interface HEMWeightPickerViewController : HEMOnboardingController

@property (nonatomic, assign) NSNumber* defaultWeightInGrams;
@property (nonatomic, weak) id<HEMWeightPickerDelegate> delegate;

@end
