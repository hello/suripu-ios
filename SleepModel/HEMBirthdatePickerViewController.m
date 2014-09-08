#import <SenseKit/SENAccount.h>

#import "HEMBirthdatePickerViewController.h"
#import "HEMUserDataCache.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerView.h"

@interface HEMBirthdatePickerViewController ()

@property (weak,   nonatomic) IBOutlet HEMBirthdatePickerView *dobPicker;
@property (weak,   nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic)          BOOL appeared;

@end

@implementation HEMBirthdatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self titleLabel] setAccessibilityLabel:NSLocalizedString(@"user.info.accessibility.birthdate-title", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self appeared]) {
        // set the picker so it's showing values somewhere in the middle and
        // the year at 18 years from this year
        [[self dobPicker] setMonth:7 day:15 yearsPast:18];
        [self setAppeared:YES];
    }
}

#pragma mark - Next

- (IBAction)next:(id)sender {
    NSInteger month = [[self dobPicker] selectedMonth];
    NSInteger day = [[self dobPicker] selectedDay];
    NSInteger yearDiff = [[self dobPicker] selectedYear];
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                   fromDate:[NSDate date]];
    NSInteger year = [components year]-yearDiff+1;
    
    [[[HEMUserDataCache sharedUserDataCache] account] setBirthMonth:month
                                                                day:day
                                                            andYear:year];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard genderSegueIdentifier]
                              sender:self];
}

@end
