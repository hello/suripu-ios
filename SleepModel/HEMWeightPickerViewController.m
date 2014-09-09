
#import <SenseKit/SENAccount.h>

#import "HEMWeightPickerViewController.h"
#import "HEMUserDataCache.h"

CGFloat const HEMWeightPickerPoundsPerKilogram = 2.20462f;
CGFloat const HEMWeightPickerKilogramsPerPound = 0.453592f;

@interface HEMWeightPickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView* weightPickerView;
@property (nonatomic, getter=isUsingImperial) BOOL usingImperial;
@end

@implementation HEMWeightPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configurePicker];
}

- (void)configurePicker
{
    NSString* currentLocaleIdentifier = [[NSLocale currentLocale] localeIdentifier];
    self.usingImperial = [currentLocaleIdentifier isEqualToString:@"en_US"] || [currentLocaleIdentifier isEqualToString:@"en_GB"];
    if ([self isUsingImperial]) {
        [self.weightPickerView selectRow:1
                             inComponent:1
                                animated:NO];
        [self.weightPickerView selectRow:150
                             inComponent:0
                                animated:NO];
    } else {
        [self.weightPickerView selectRow:0
                             inComponent:1
                                animated:NO];
        [self.weightPickerView selectRow:80
                             inComponent:0
                                animated:NO];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 0 ? 800 : 2;
}

- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString* contentString = nil;
    if (component == 0) {
        contentString = [NSString stringWithFormat:@"%ld", (long)row];
    } else if (row == 0) {
        contentString = NSLocalizedString(@"measurement.kg.unit", nil);
    } else {
        contentString = NSLocalizedString(@"measurement.lb.unit", nil);
    }
    return [[NSAttributedString alloc] initWithString:contentString attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        NSInteger value = 0;
        if ([self isUsingImperial]) {
            value = [self valueInKilograms:row];
        } else {
            value = row;
        }
        [[[HEMUserDataCache sharedUserDataCache] account] setWeight:@(value)];
    } else if (component == 1 && !([self isUsingImperial] == (row == 1))) {
        self.usingImperial = (row == 1);
        NSInteger selectedRow = [self.weightPickerView selectedRowInComponent:0];
        if ([self isUsingImperial]) {
            selectedRow = [self valueInPounds:selectedRow];
        } else {
            selectedRow = [self valueInKilograms:selectedRow];
        }
        [self.weightPickerView selectRow:selectedRow inComponent:0 animated:NO];
    }
}

- (NSInteger)valueInPounds:(NSInteger)value
{
    return ceilf(value * HEMWeightPickerPoundsPerKilogram);
}

- (NSInteger)valueInKilograms:(NSInteger)value
{
    return floorf(value * HEMWeightPickerKilogramsPerPound);
}

- (CGFloat)pickerView:(UIPickerView*)pickerView widthForComponent:(NSInteger)component
{
    return 60.f;
}

@end
