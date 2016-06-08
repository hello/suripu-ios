
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingService.h"
#import "HEMLocationService.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"
#import "HEMLocationRequestPresenter.h"

@interface HEMLocationFinderViewController () <HEMLocationRequestPresenterDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (strong, nonatomic) HEMLocationService* locationService;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [self configurePresenter];
    [self trackAnalyticsEvent:HEMAnalyticsEventLocation];
}

- (void)configurePresenter {
    [self setLocationService:[HEMLocationService new]];
    HEMLocationRequestPresenter* presenter =
        [[HEMLocationRequestPresenter alloc] initWithLocationService:[self locationService]
                                                andOnboardingService:[HEMOnboardingService sharedService]];
    [presenter bindWithLocationButton:[self locationButton]];
    [presenter bindWithSkipButton:[self skipButton]];
    [presenter setDelegate:self];
    [self addPresenter:presenter];
}

#pragma mark - Presenter Delegate

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message from:(HEMLocationRequestPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

- (void)proceedFrom:(HEMLocationRequestPresenter *)presenter {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard locationToPushSegueIdentifier]
                              sender:self];
}

@end
