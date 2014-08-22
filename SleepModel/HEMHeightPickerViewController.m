#import <SenseKit/SENSettings.h>

#import "HEMHeightPickerViewController.h"
#import "HEMUserDataCache.h"
#import "HEMValueSliderView.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;
static NSInteger HEMMaxHeightInFeet = 9;

@interface HEMHeightPickerViewController () <HEMValueSliderDelegate>

@property (nonatomic, getter=isUsingImperial) BOOL usingImperial;
@property (weak, nonatomic) IBOutlet HEMValueSliderView *heightSliderView;
@property (assign, nonatomic) NSInteger numberOfRows;
@property (weak, nonatomic) IBOutlet UILabel *mainHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherHeightLabel;

@end

@implementation HEMHeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNumberOfRows:HEMMaxHeightInFeet+1]; // include 0
    [[self heightSliderView] reload];
    [[self heightSliderView] setToValue:HEMMaxHeightInFeet - (5 + (8/12.0f))];
}

#pragma mark - HEMValueSliderDelegate

- (NSInteger)numberOfRowsInSliderView:(HEMValueSliderView *)sliderView {
    return [self numberOfRows];
}

- (NSNumber*)sliderView:(HEMValueSliderView *)sliderView numberForRow:(NSInteger)row {
    return @([self numberOfRows]-row-1); // show numbers in reverse
}

- (float)incrementalValuePerRowInSliderView:(HEMValueSliderView *)sliderView {
    return -1; // it's in reverse
}

- (void)sliderView:(HEMValueSliderView *)sliderView didScrollToValue:(float)value {
    NSInteger inches = (int)(roundf((value - (long)floorf(value))*12));
    NSInteger feet = (int)floorf(value);
    NSInteger cm = value * 12 * HEMHeightPickerCentimetersPerInch;
    
    if (inches == 12) {
        inches = 0;
        feet += 1;
    }
    
    NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
    NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
    NSString* cmFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cm];
    [[self mainHeightLabel] setText:[NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat]];
    [[self otherHeightLabel] setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"measurement.or", nil), cmFormat]];
    
    [[HEMUserDataCache sharedUserDataCache] setHeightInCentimeters:@(cm)];
}

@end
