
#import "Sense-Swift.h"

#import "HEMAlarmListViewController.h"
#import "HEMAlarmListPresenter.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmAddButton.h"
#import "HEMMainStoryboard.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSettingsNavigationController.h"
#import "HEMSensePairViewController.h"
#import "HEMAlertViewController.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"
#import "HEMAlarmService.h"
#import "HEMSupportUtil.h"
#import "HEMExpansionService.h"
#import "HEMShortcutService.h"

@interface HEMAlarmListViewController () <
    HEMAlarmControllerDelegate,
    HEMAlarmListPresenterDelegate,
    HEMPresenterPairDelegate,
    HEMSensePairingDelegate,
    ShortcutHandler,
    Scrollable
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton *addButton;

@property (nonatomic, strong) HEMAlarmService* alarmService;
@property (nonatomic, strong) HEMExpansionService* expansionService;
@property (nonatomic, weak) HEMAlarmListPresenter* alarmsPresenter;
@property (nonatomic, assign) BOOL launchNewAlarmOnLoad;

@end

@implementation HEMAlarmListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _tabIcon = [UIImage imageNamed:@"soundsTabBarIcon"];
        _tabIconHighlighted = [UIImage imageNamed:@"soundsTabBarIconHighlighted"];
        _tabTitle = NSLocalizedString(@"alarms.title", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    HEMAlarmService* alarmService = [HEMAlarmService new];
    HEMExpansionService* expansionService = [HEMExpansionService new];
    
    HEMAlarmListPresenter* alarmPresenter
        = [[HEMAlarmListPresenter alloc] initWithAlarmService:alarmService
                                             expansionService:expansionService
                                                deviceService:[self deviceService]];
    [alarmPresenter bindWithCollectionView:[self collectionView]];
    [alarmPresenter bindWithSubNavigationView:[self subNav]];
    [alarmPresenter bindWithDataLoadingIndicator:[self loadingIndicator]];
    [alarmPresenter bindWithAddButton:[self addButton]];
    [alarmPresenter setDelegate:self];
    [alarmPresenter setPairDelegate:self];
    
    [self setAlarmsPresenter:alarmPresenter];
    [self setAlarmService:alarmService];
    [self setExpansionService:expansionService];
    [self addPresenter:alarmPresenter];
}

- (void)presentViewControllerForAlarm:(SENAlarm *)alarm {
    UINavigationController *controller = (UINavigationController *)[HEMMainStoryboard instantiateAlarmNavController];
    if ([controller isKindOfClass:[HEMSettingsNavigationController class]]) {
        HEMSettingsNavigationController* settingsNav = (id)controller;
        [settingsNav setManuallyHandleDrawerVisibility:YES];
    }
    HEMAlarmViewController *alarmController = (HEMAlarmViewController *)controller.topViewController;
    alarmController.alarm = alarm;
    alarmController.deviceService = self.deviceService;
    alarmController.alarmService = self.alarmService;
    alarmController.expansionService = self.expansionService;
    alarmController.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)addNewAlarm {
    SENAlarm *alarm = [SENAlarm createDefaultAlarm];
    [self presentViewControllerForAlarm:alarm];
}

#pragma mark - Scrollable

- (void)scrollToTop {
    [[self collectionView] setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Shortcuts

- (BOOL)canHandleActionWithAction:(HEMShortcutAction)action {
    switch (action) {
        case HEMShortcutActionAlarmEdit:
        case HEMShortcutActionAlarmNew:
            return YES;
        default:
            return NO;
    }
}

- (void)takeActionWithAction:(HEMShortcutAction)action {
    switch (action) {
        case HEMShortcutActionAlarmEdit:
            [SENAnalytics track:HEMAnalyticsEventShortcutAlarmEdit];
            break;
        case HEMShortcutActionAlarmNew:
            [SENAnalytics track:HEMAnalyticsEventShortcutAlarmNew];
            [self addNewAlarmFromShortcut];
            break;
        default:
            break;
    }
}

- (void)addNewAlarmFromShortcut {
    if ([[self alarmsPresenter] isLoading]) {
        [self setLaunchNewAlarmOnLoad:YES];
    } else {
        [self addNewAlarm];
    }
}

#pragma mark - HEMAlarmListPresenterDelegate

- (void)addNewAlarmFromPresenter:(HEMAlarmListPresenter*)presenter {
    [self addNewAlarm];
}

- (void)didFinishLoadingDataFrom:(HEMAlarmListPresenter *)presenter {
    if ([self launchNewAlarmOnLoad]) {
        [self addNewAlarm];
        [self setLaunchNewAlarmOnLoad:NO];
    }
}

- (void)didSelectAlarm:(SENAlarm*)alarm fromPresenter:(HEMAlarmListPresenter*)presenter {
    [self presentViewControllerForAlarm:alarm];
}

- (void)showErrorWithTitle:(NSString *)title
                   message:(NSString *)message
             fromPresenter:(HEMAlarmListPresenter *)presenter {
    HEMAlertViewController* dialogVC =
    [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [dialogVC setViewToShowThrough:[[self rootViewController] view]];
    [dialogVC addButtonWithTitle:NSLocalizedString(@"actions.ok", nil)
                           style:HEMAlertViewButtonStyleRoundRect
                          action:nil];
    [dialogVC showFrom:self];
}

#pragma mark - HEMAlarmControllerDelegate

- (void)didCancelAlarmFrom:(HEMAlarmViewController *)alarmVC {
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSaveAlarm:(SENAlarm *)alarm from:(HEMAlarmViewController *)alarmVC {
    [[self alarmsPresenter] update];
    [alarmVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMPresenterPairDelegate

- (void)pairSenseFrom:(HEMPresenter *)presenter {
    HEMSensePairViewController *pairVC = (id)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - HEMSensePairingDelegate

- (void)didPairSenseUsing:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self dismissModalAfterDelay:senseManager != nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager*)senseManager from:(UIViewController*)controller {
    [self dismissModalAfterDelay:senseManager != nil];
}

@end
