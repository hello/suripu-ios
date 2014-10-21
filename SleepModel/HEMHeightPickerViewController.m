#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAccount.h>
#import "HEMHeightPickerViewController.h"
#import "HEMUserDataCache.h"
#import "HEMValueSliderView.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;
static NSInteger HEMMaxHeightInFeet = 9;

@interface HEMHeightPickerViewController () <HEMValueSliderDelegate>

@property (nonatomic, getter=isUsingImperial) BOOL usingImperial;
@property (weak, nonatomic) IBOutlet HEMValueSliderView *heightSliderView;
@property (assign, nonatomic) NSInteger numberOfRows;
@property (assign, nonatomic) int selectedHeightInCm;
@property (weak, nonatomic) IBOutlet UILabel *mainHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherHeightLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@end

@implementation HEMHeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[super navigationItem] setHidesBackButton:YES];
    [self setNumberOfRows:HEMMaxHeightInFeet+1]; // include 0
    [[self heightSliderView] reload];
    
    NSInteger feet = [self feet] > 0 ? [self feet] : 5;
    NSInteger inch = [self inches] > 0 ? [self inches] : 8;
    [[self heightSliderView] setToValue:HEMMaxHeightInFeet - (feet + (inch/12.0f))];
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
    }
    
    [SENAnalytics track:kHEMAnalyticsEventOnBHeight];
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
    NSInteger cm = ceilf(((feet * 12) + inches) * HEMHeightPickerCentimetersPerInch);
    
    if (inches == 12) {
        inches = 0;
        feet += 1;
    }
    
    NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
    NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
    NSString* cmFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cm];
    [[self mainHeightLabel] setText:[NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat]];
    [[self otherHeightLabel] setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"measurement.or", nil), cmFormat]];
    
    [self setSelectedHeightInCm:(int)cm];
    [[[HEMUserDataCache sharedUserDataCache] account] setHeight:@(cm)];
}

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectHeightInCentimeters:[self selectedHeightInCm] from:self];
    } else {
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard weightSegueIdentifier]
                                  sender:self];
    }
}

@end
