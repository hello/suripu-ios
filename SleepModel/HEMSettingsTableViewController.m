#import <MessageUI/MessageUI.h>

#import "HEMSettingsTableViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMTellAFriendItemProvider.h"

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

@end

@implementation HEMSettingsTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"settings.title", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"settingsBarIcon"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"settingsBarIconActive"];
        
        [self updateBadge];
    }
    return self;
}

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
    [presenter bindWithActivityView:[self activityView]];
    [presenter setDelegate:self];
    
    [self addPresenter:presenter];
    [self setExpansionService:expansionService];
    [self setDeviceService:deviceService];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventSettings];
}

- (void)didRefreshAccount {
    [self updateBadge];
}

- (void)updateBadge {
    BOOL showBadge = [self showIndicatorForCrumb:HEMBreadcrumbSettings];
    self.tabBarItem.badgeValue = showBadge ? @"1" : nil;
    [self reloadTopBar];
}

- (NSString *)segueIdentifierForCategory:(HEMSettingsCategory)category {
    switch (category) {
        case HEMSettingsCategoryProfile:
            return [HEMMainStoryboard accountSettingsSegueIdentifier];
        case HEMSettingsCategoryDevices:
            return [HEMMainStoryboard devicesSettingsSegueIdentifier];
        case HEMSettingsCategoryPreferences:
            return [HEMMainStoryboard unitsSettingsSegueIdentifier];
        case HEMSettingsCategoryNotifications:
            return [HEMMainStoryboard notificationSettingsSegueIdentifier];
        case HEMSettingsCategorySupport:
            return [HEMMainStoryboard settingsToSupportSegueIdentifier];
        case HEMSettingsCategoryExpansions:
            return [HEMMainStoryboard expansionsSegueIdentifier];
        default:
            return nil; // others show modal
    }
}

#pragma mark - Settings Delegate

- (void)didSelectSettingsCategory:(HEMSettingsCategory)category
                    fromPresenter:(HEMSettingsPresenter*)presenter {
    NSString* segueId = [self segueIdentifierForCategory:category];
    if (segueId) {
        [self performSegueWithIdentifier:segueId sender:self];
    }
}

- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMSettingsPresenter*)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
