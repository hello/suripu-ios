
#import <SenseKit/SENAccount.h>

#import "Sense-Swift.h"

#import "HEMGenderPickerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMActionButton.h"
#import "HEMAccountUpdateDelegate.h"
#import "HEMListItemSelectionViewController.h"
#import "HEMSettingsNavigationController.h"
#import "HEMMainStoryboard.h"

@interface HEMGenderPickerViewController () <GenderUpdateDelegate, HEMListDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;

@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad {
    [self configurePresenter]; // need to go before viewDidLoad
    
    [super viewDidLoad];
    // styling of the buttons should be done in the presenter, but since this is
    // an onboarding controller, the styling is done at the controller level
    [self stylePrimaryButton:[self doneButton]
             secondaryButton:[self skipButton]
                withDelegate:[self delegate] != nil];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventGender];
}

- (void)configurePresenter {
    if (![self account]) {
        SENAccount* onboardingAccount = [[HEMOnboardingService sharedService] currentAccount];
        if (!onboardingAccount) {
            onboardingAccount = [SENAccount new];
        }
        [self setAccount:onboardingAccount];
    }
    
    GenderSelectorPresenter* presenter =
        [[GenderSelectorPresenter alloc] initWithAccount:[self account]
                                       onboardingService:[HEMOnboardingService sharedService]];
    
    [presenter bindWithNextButton:[self doneButton]];
    [presenter bindWithSkipButton:[self skipButton]];
    [presenter bindWithOptionsTable:[self optionsTableView]];
    [presenter bindWithTitleLabel:[self titleLabel]];
    [presenter bindWithDescriptionLabel:[self descriptionLabel]];
    [presenter setUpdateDelegate:self];
    
    [self addPresenter:presenter];
}

#pragma mark - GenderUpdateDelegate

- (void)didUpdateWithAccount:(SENAccount *)account from:(GenderSelectorPresenter *)presenter {
    if ([self delegate]) {
        [[self delegate] update:account];
    } else {
        [self next];
    }
}

- (void)didSkipFrom:(GenderSelectorPresenter *)presenter {
    if ([self delegate]) {
        [[self delegate] cancel];
    } else {
        [self next];
    }
}

- (void)showOtherOptionsWith:(OtherGenderOptionsPresenter *)optionsPresenter
                        from:(GenderSelectorPresenter *)presenter {
    HEMListItemSelectionViewController* listVC = (id)[HEMMainStoryboard instantiateListItemViewController];
    [listVC setListPresenter:optionsPresenter];

    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismissOtherOptionsFromFrom:(GenderSelectorPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Continuation

- (void)next {
    // update analytics property for gender
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard heightSegueIdentifier]
                              sender:self];
}

@end
