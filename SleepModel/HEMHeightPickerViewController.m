#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMHeightPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HEMValueSliderView.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMBaseController+Protected.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;
static NSInteger HEMMaxHeightInFeet = 9;

@interface HEMHeightPickerViewController () <HEMValueSliderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, getter=isUsingImperial) BOOL usingImperial;
@property (weak, nonatomic) IBOutlet HEMValueSliderView *heightSliderView;
@property (assign, nonatomic) NSInteger numberOfRows;
@property (assign, nonatomic) int selectedHeightInCm;
@property (weak, nonatomic) IBOutlet UILabel *mainHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherHeightLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightSliderHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowBottomAlignmentConstraint;

@end

@implementation HEMHeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[super navigationItem] setHidesBackButton:YES];
    
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setNumberOfRows:HEMMaxHeightInFeet+1]; // include 0
    [[self heightSliderView] reload];
    
    [[self subtitleLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
    
    NSInteger feet = [self feet] > 0 ? [self feet] : 5;
    NSInteger inch = [self inches] > 0 ? [self inches] : 8;
    [[self heightSliderView] setToValue:(feet + (inch/12.0f))];
    
    if ([self delegate] != nil) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:done forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [SENAnalytics track:kHEMAnalyticsEventOnBHeight];
    }

}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self heightSliderHeightConstraint] withDiff:-80.0f];
    [self updateConstraint:[self arrowHeightConstraint] withDiff:-20.0f];
    [self updateConstraint:[self arrowBottomAlignmentConstraint] withDiff:40.0f];
}

#pragma mark - HEMValueSliderDelegate

- (NSInteger)numberOfRowsInSliderView:(HEMValueSliderView *)sliderView {
    return [self numberOfRows];
}

- (NSNumber*)sliderView:(HEMValueSliderView *)sliderView numberForRow:(NSInteger)row {
    return @(row);
}

- (float)incrementalValuePerRowInSliderView:(HEMValueSliderView *)sliderView {
    return 1;
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
    [[[HEMOnboardingCache sharedCache] account] setHeight:@(cm)];
}

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectHeightInCentimeters:[self selectedHeightInCm] from:self];
    } else {
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didCancelHeightFrom:self];
    } else {
        [self next];
    }
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard weightSegueIdentifier]
                              sender:self];
}

@end
