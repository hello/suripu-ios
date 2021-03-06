#import <SenseKit/SENAccount.h>
#import <SenseKit/SENAPIAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMBirthdatePickerViewController.h"
#import "HEMOnboardingService.h"
#import "UIColor+HEMStyle.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerView.h"
#import "HEMActionButton.h"
#import "HEMAccountUpdateDelegate.h"

static NSInteger const kHEMBirthdatePickerDefaultMonth = 7;
static NSInteger const kHEMBirthdatePickerDefaultDay = 15;
static NSInteger const kHEMBirthdatePickerDefaultYear = 18;

@interface HEMBirthdatePickerViewController ()

@property (weak,   nonatomic) IBOutlet HEMBirthdatePickerView *dobPicker;
@property (assign, nonatomic)          BOOL appeared;
@property (weak,   nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak,   nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMBirthdatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self preLoadAccount]; // if does not yet exist, in case user returns to here
    [self configureButtons];

    if (![self updateDelegate]) {
        // start looking for a sense right away here.  We want this step here b/c
        // this is one of the checkpoints and if user lands back here, this optimizatin
        // will also apply.  If there is a delegate, we do not want to pre scan
        // as it should already be set up.
        [[HEMOnboardingService sharedService] preScanForSenses];
    }
    
    [self trackAnalyticsEvent:HEMAnalyticsEventBirthday];
}

- (void)preLoadAccount {
    [[HEMOnboardingService sharedService] loadCurrentAccount:nil];
}

- (void)configureButtons {
    [self stylePrimaryButton:[self doneButton]
             secondaryButton:[self skipButton]
                withDelegate:[self updateDelegate] != nil];
    
    [self enableBackButton:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self appeared]) {
        // set the picker so it's showing values somewhere in the middle and
        // the year at 18 years from this year
        NSInteger defaultMonth = [self initialMonth] > 0 ? [self initialMonth] : kHEMBirthdatePickerDefaultMonth;
        NSInteger defaultDay = [self initialDay] > 0 ? [self initialDay] : kHEMBirthdatePickerDefaultDay;
        NSInteger defaultYear = [self initialYear] > 0 ? [self initialYear]+1 : kHEMBirthdatePickerDefaultYear;
        [[self dobPicker] setMonth:defaultMonth day:defaultDay yearsPast:defaultYear];
        [self setAppeared:YES];
    }
}

#pragma mark - Errors

- (void)showIssueLoadingAccountAlert {
    [self showMessageDialog:NSLocalizedString(@"onboarding.account.dob-not-updated", nil)
                      title:NSLocalizedString(@"onboarding.account.not-loaded-title", nil)];
}

#pragma mark - Next

- (IBAction)next:(id)sender {
    NSInteger month = [[self dobPicker] selectedMonth];
    NSInteger day = [[self dobPicker] selectedDay];
    NSInteger year = [[self dobPicker] selectedYear];
    
    if (![self updateDelegate]) {
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        
        if ([service currentAccount] == nil) {
            [self loadAccountThenProceedWithMonth:month day:day year:year];
        } else {
            [[service currentAccount] setBirthMonth:month day:day andYear:year];
            [self proceedToNextScreen];
        }
    } else {
        SENAccount* tempAccount = [SENAccount new];
        [tempAccount setBirthMonth:month day:day andYear:year];
        [[self updateDelegate] update:tempAccount];
    }
}

- (IBAction)skip:(id)sender {
    if ([self updateDelegate]) {
        [[self updateDelegate] cancel];
    } else {
        [self proceedToNextScreen];
    }
}

- (void)loadAccountThenProceedWithMonth:(NSInteger)month day:(NSInteger)day year:(NSInteger)year {
    __weak typeof(self) weakSelf = self;
    [[HEMOnboardingService sharedService] loadCurrentAccount:^(SENAccount *account, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                [strongSelf showIssueLoadingAccountAlert];
            } else {
                [account setBirthMonth:month day:day andYear:year];
                [strongSelf proceedToNextScreen];
            }
        }
    }];
}

- (void)proceedToNextScreen {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard genderSegueIdentifier]
                              sender:self];
}

@end
