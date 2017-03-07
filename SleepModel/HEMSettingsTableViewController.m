#import <MessageUI/MessageUI.h>

#import "Sense-Swift.h"

#import "HEMSettingsTableViewController.h"
#import "HEMVoiceSettingsViewController.h"
#import "HEMSettingsStoryboard.h"
#import "HEMTellAFriendItemProvider.h"
#import "HEMListItemSelectionViewController.h"

#import "HEMSettingsPresenter.h"
#import "HEMBreadcrumbService.h"
#import "HEMAccountService.h"
#import "HEMDeviceService.h"
#import "HEMExpansionService.h"
#import "HEMActivityIndicatorView.h"

@interface HEMSettingsTableViewController () <HEMSettingsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityView;

@property (strong, nonatomic) HEMExpansionService* expansionService;
@property (strong, nonatomic) HEMDeviceService* deviceService;
@property (weak, nonatomic) HEMBreadcrumbService* breadService;
@property (strong, nonatomic) NightModeService* nightModeService;

@end

@implementation HEMSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [self clearCrumb:HEMBreadcrumbSettings];
    [self updateBadge];
}

- (void)configurePresenter {
    HEMAccountService* accountService = [HEMAccountService sharedService];
    SENAccount* account = [accountService account];
    HEMBreadcrumbService* breadService = [HEMBreadcrumbService sharedServiceForAccount:account];
    HEMDeviceService* deviceService = [HEMDeviceService new];
    HEMExpansionService* expansionService = [HEMExpansionService new];
    
    HEMSettingsPresenter* presenter =
        [[HEMSettingsPresenter alloc] initWithDeviceService:deviceService
                                           expansionService:expansionService
                                          breadCrumbService:breadService];
    [presenter bindWithTableView:[self settingsTableView]];
    [presenter bindWithNavItem:[self navigationItem]];
    [presenter bindWithActivityView:[self activityView]];
    [presenter setDelegate:self];
    
    [self addPresenter:presenter];
    [self setExpansionService:expansionService];
    [self setDeviceService:deviceService];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self categoryToShow] != HEMSettingsCategoryMain) {
        [self showCategory:[self categoryToShow]];
        [self setCategoryToShow:HEMSettingsCategoryMain]; // clear it after
    }
    [SENAnalytics track:kHEMAnalyticsEventSettings];
}

- (void)didRefreshAccount {
    [self updateBadge];
}

- (void)updateBadge {
    BOOL showBadge = [self showIndicatorForCrumb:HEMBreadcrumbSettings];
    self.tabBarItem.badgeValue = showBadge ? @"1" : nil;
}

- (NSString *)segueIdentifierForCategory:(HEMSettingsCategory)category {
    switch (category) {
        case HEMSettingsCategoryProfile:
            return [HEMSettingsStoryboard accountSettingsSegueIdentifier];
        case HEMSettingsCategoryDevices:
            return [HEMSettingsStoryboard devicesSettingsSegueIdentifier];
        case HEMSettingsCategoryNotifications:
            return [HEMSettingsStoryboard notificationSettingsSegueIdentifier];
        case HEMSettingsCategorySupport:
            return [HEMSettingsStoryboard settingsToSupportSegueIdentifier];
        case HEMSettingsCategoryExpansions:
            return [HEMSettingsStoryboard expansionsSegueIdentifier];
        case HEMSettingsCategoryVoice:
            return [HEMSettingsStoryboard voiceSegueIdentifier];
        default:
            return nil; // others show modal
    }
}

- (void)showNightModeSettings {
    if (![self nightModeService]) {
        [self setNightModeService:[NightModeService new]];
    }
    NightModeSettingsPresenter* presenter = [[NightModeSettingsPresenter alloc] initWithNightModeService:[self nightModeService]];
    HEMListItemSelectionViewController* listVC = [HEMMainStoryboard instantiateListItemViewController];
    [listVC setListPresenter:presenter];
    [[self navigationController] pushViewController:listVC animated:YES];
}

#pragma mark - Shortcuts

- (void)showCategory:(HEMSettingsCategory)category {
    NSString* segueId = [self segueIdentifierForCategory:category];
    if (segueId) {
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

#pragma mark - Settings Delegate

- (void)didSelectSettingsCategory:(HEMSettingsCategory)category
                    fromPresenter:(HEMSettingsPresenter*)presenter {
    switch (category) {
        case HEMSettingsCategoryNightMode:
            [self showNightModeSettings];
            break;
        default:
            [self showCategory:category];
    }
}

- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMSettingsPresenter*)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMVoiceSettingsViewController class]]) {
        HEMVoiceSettingsViewController* voiceVC = destVC;
        [voiceVC setDeviceService:[self deviceService]];
    }
}

@end
