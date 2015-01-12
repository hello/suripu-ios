#import <SenseKit/SENAccount.h>
#import <SenseKit/SENAPIAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMBirthdatePickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBirthdatePickerView.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"

static NSInteger const kHEMBirthdatePickerDefaultMonth = 7;
static NSInteger const kHEMBirthdatePickerDefaultDay = 15;
static NSInteger const kHEMBirthdatePickerDefaultYear = 18;

@interface HEMBirthdatePickerViewController ()

@property (weak,   nonatomic) IBOutlet HEMBirthdatePickerView *dobPicker;
@property (weak,   nonatomic) IBOutlet UILabel *subtitleLabel;
@property (assign, nonatomic)          BOOL appeared;
@property (weak,   nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak,   nonatomic) IBOutlet UIButton *skipButton;

@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *dobPickerHeightConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *dobPickerToButtonTopConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *doneButtonWidthConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *dobPickerCenterYConstraint;

@end

@implementation HEMBirthdatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString* msg = NSLocalizedString(@"user.info.accessibility.birthdate-title", nil);
    [[self titleLabel] setAccessibilityLabel:msg];

    [self loadAccount:nil]; // if does not yet exist, in case user returns to here
    [[self subtitleLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
    
    if ([self delegate] != nil) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:done forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [self enableBackButton:NO];
        // start looking for a sense right away here.  We want this step here b/c
        // this is one of the checkpoints and if user lands back here, this optimizatin
        // will also apply.  If there is a delegate, we do not want to pre scan
        // as it should already be set up.
        [[HEMOnboardingCache sharedCache] preScanForSenses];
        [SENAnalytics track:kHEMAnalyticsEventOnBBirthday];
    }
    
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
    CGFloat heightDiff = -kHEMBirthdateValueHeight;
    [self updateConstraint:[self dobPickerHeightConstraint] withDiff:heightDiff];
    [self updateConstraint:[self dobPickerToButtonTopConstraint] withDiff:-heightDiff];
    
    [self updateConstraint:[self dobPickerCenterYConstraint] withDiff:-20.0f];
}

- (void)loadAccount:(void(^)(NSError* error))completion {
    if ([[HEMOnboardingCache sharedCache] account] == nil) {
        [SENAPIAccount getAccount:^(SENAccount* account, NSError *error) {
            if (account != nil) {
                [[HEMOnboardingCache sharedCache] setAccount:account];
            }
            if (completion) completion (error);
        }];
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
    
    if ([self delegate] == nil) {
        HEMOnboardingCache* cache = [HEMOnboardingCache sharedCache];
        
        if ([cache account] == nil) {
            [self loadAccountThenProceedWithMonth:month day:day year:year];
        } else {
            [[cache account] setBirthMonth:month day:day andYear:year];
            [self proceedToNextScreen];
        }

    } else {
        [[self delegate] didSelectMonth:month day:day year:year from:self];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didCancelBirthdatePicker:self];
    } else {
        [self proceedToNextScreen];
    }
}

- (void)loadAccountThenProceedWithMonth:(NSInteger)month day:(NSInteger)day year:(NSInteger)year {
    [[self doneButton] showActivityWithWidthConstraint:[self doneButtonWidthConstraint]];
    
    __weak typeof(self) weakSelf = self;
    [self loadAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf doneButton] stopActivity];
            
            if (error != nil) {
                [strongSelf showIssueLoadingAccountAlert];
            } else {
                [[[HEMOnboardingCache sharedCache] account] setBirthMonth:month
                                                                            day:day
                                                                        andYear:year];
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
