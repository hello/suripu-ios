
#import <SenseKit/SENAccount.h>

#import "Sense-Swift.h"

#import "HEMGenderPickerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMActionButton.h"
#import "HEMAccountUpdateDelegate.h"
#import "HEMBasicTableViewCell.h"

@interface HEMGenderPickerViewController () <GenderUpdateDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UITableView *optionsTableView;
@property (strong, nonatomic) SENAccount* account;

@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [self trackAnalyticsEvent:HEMAnalyticsEventGender];
}

- (void)configurePresenter {
    if ([self delegate]) {
        [self setAccount:[SENAccount new]];
    } else {
        [self setAccount:[[HEMOnboardingService sharedService] currentAccount]];
    }
    
    GenderSelectorPresenter* presenter = [[GenderSelectorPresenter alloc] initWithAccount:[self account]];
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

#pragma mark - Continuation

- (void)next {
    // update analytics property for gender
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard heightSegueIdentifier]
                              sender:self];
}

@end
