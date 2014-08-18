#import <SenseKit/SENSettings.h>

#import "HEMHeightPickerViewController.h"
#import "HEMUserDataCache.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;

@interface HEMHeightPickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl* unitFormatSegmentControl;
@property (nonatomic, getter=isUsingImperial) BOOL usingImperial;
@property (weak, nonatomic) IBOutlet UIPickerView* heightPickerView;
@end

@implementation HEMHeightPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* currentLocaleIdentifier = [[NSLocale currentLocale] localeIdentifier];
    self.usingImperial = [currentLocaleIdentifier isEqualToString:@"en_US"] || [currentLocaleIdentifier isEqualToString:@"en_GB"];
    [self setDefaultValues];
}

- (void)setDefaultValues
{
    if ([self isUsingImperial]) {
        self.unitFormatSegmentControl.selectedSegmentIndex = 1;
        [self.heightPickerView selectRow:5 inComponent:0 animated:NO];
        [self.heightPickerView selectRow:8 inComponent:1 animated:NO];
    } else {
        self.unitFormatSegmentControl.selectedSegmentIndex = 0;
        [self.heightPickerView selectRow:160 inComponent:0 animated:NO];
    }
}

- (IBAction)updateUnitFormat:(UISegmentedControl*)sender
{
    self.usingImperial = sender.selectedSegmentIndex == 1;
    [self.heightPickerView reloadAllComponents];
    [self setDefaultValues];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self isUsingImperial]) {
        if (component == 0) {
            return 9;
        } else {
            return 12;
        }
    } else {
        if (component == 0) {
            return 275;
        } else {
            return 1;
        }
    }
}

- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString* contentString = nil;
    if ([self isUsingImperial]) {
        if (component == 0) {
            contentString = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)row];
        } else {
            contentString = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)row];
        }
    } else {
        if (component == 0) {
            contentString = [NSString stringWithFormat:@"%ld", (long)row + 1];
        } else {
            contentString = NSLocalizedString(@"measurement.cm.unit", nil);
        }
    }
    return [[NSAttributedString alloc] initWithString:contentString attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    CGFloat centimeters = 0;
    if ([self isUsingImperial]) {
        NSInteger feet = [pickerView selectedRowInComponent:0];
        NSInteger inches = [pickerView selectedRowInComponent:1];
        centimeters = ((feet * 12.f) + inches) * HEMHeightPickerCentimetersPerInch;
    } else {
        centimeters = (CGFloat)[pickerView selectedRowInComponent : 0];
    }
    [[HEMUserDataCache sharedUserDataCache] setHeightInCentimeters:@(centimeters)];
}

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component
{
    return 80.f;
}

@end
