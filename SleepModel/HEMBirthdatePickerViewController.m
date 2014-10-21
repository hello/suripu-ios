#import <SenseKit/SENAccount.h>

#import "HEMBirthdatePickerViewController.h"
#import "HEMUserDataCache.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerView.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"

static NSInteger const kHEMBirthdatePickerDefaultMonth = 7;
static NSInteger const kHEMBirthdatePickerDefaultDay = 15;
static NSInteger const kHEMBirthdatePickerDefaultYear = 18;

@interface HEMBirthdatePickerViewController ()

@property (weak,   nonatomic) IBOutlet HEMBirthdatePickerView *dobPicker;
@property (weak,   nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic)          BOOL appeared;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dobPickerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dobPickerToButtonTopConstraint;

@end

@implementation HEMBirthdatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [[self titleLabel] setAccessibilityLabel:NSLocalizedString(@"user.info.accessibility.birthdate-title", nil)];
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
    }
    
    [SENAnalytics track:kHEMAnalyticsEventOnBBirthday];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self appeared]) {
        // set the picker so it's showing values somewhere in the middle and
        // the year at 18 years from this year
        NSInteger defaultMonth = [self initialMonth] > 0 ? [self initialMonth] : kHEMBirthdatePickerDefaultMonth;
        NSInteger defaultDay = [self initialDay] > 0 ? [self initialDay]+1 : kHEMBirthdatePickerDefaultDay;
        NSInteger defaultYear = [self initialYear] > 0 ? [self initialYear]+1 : kHEMBirthdatePickerDefaultYear;
        [[self dobPicker] setMonth:defaultMonth day:defaultDay yearsPast:defaultYear];
        [self setAppeared:YES];
    }
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat heightDiff = -2 * kHEMBirthdateValueHeight; // show 3 rows instead
    [self updateConstraint:[self dobPickerHeightConstraint] withDiff:heightDiff];
    [self updateConstraint:[self dobPickerToButtonTopConstraint] withDiff:-heightDiff];
}

#pragma mark - Next

- (IBAction)next:(id)sender {
    NSInteger month = [[self dobPicker] selectedMonth];
    NSInteger day = [[self dobPicker] selectedDay];
    NSInteger yearDiff = [[self dobPicker] selectedYear];
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                   fromDate:[NSDate date]];
    NSInteger year = [components year]-yearDiff+1;
    
    if ([self delegate] == nil) {
        [[[HEMUserDataCache sharedUserDataCache] account] setBirthMonth:month
                                                                    day:day
                                                                andYear:year];
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard genderSegueIdentifier]
                                  sender:self];
    } else {
        [[self delegate] didSelectMonth:month day:day year:year from:self];
    }
}

@end
