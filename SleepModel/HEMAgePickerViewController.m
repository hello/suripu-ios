
#import "HEMAgePickerViewController.h"
#import "HEMUserDataCache.h"

@interface HEMAgePickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView* agePickerView;
@end

@implementation HEMAgePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.agePickerView selectRow:29 inComponent:0 animated:NO];
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return component == 0 ? 130 : 0;
}

- (NSAttributedString*)pickerView:(UIPickerView*)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", [self ageForRow:row]] attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
}

- (long)ageForRow:(NSInteger)row
{
    return (long)row + 1;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView*)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[HEMUserDataCache sharedUserDataCache] setAge:@([self ageForRow:row])];
}

@end
