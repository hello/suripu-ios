#import <MessageUI/MessageUI.h>
#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMSettingsTableViewController.h"
#import "HEMSettingsTableViewCell.h"
#import "HEMMainStoryboard.h"
#import "HEMLogUtils.h"
#import "HEMTellAFriendItemProvider.h"
#import "HEMBreadcrumbService.h"
#import "HEMAccountService.h"

static CGFloat const HEMSettingsBottomMargin = 10.0f;

typedef NS_ENUM(NSUInteger, HEMSettingsAccountRow) {
    HEMSettingsAccountRowIndex = 0,
    HEMSettingsDevicesRowIndex,
    HEMSettingsNotificationRowIndex,
    HEMSettingsUnitsTimeRowIndex,
    HEMSettingsAccountRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsSupportRow) {
    HEMSettingsSupportRowIndex = 0,
    HEMSettingsSupportRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsTellAFriendRow) {
    HEMSettingsTellAFriendRowIndex = 0,
    HEMSettingsTellAFriendRowCount
};

typedef NS_ENUM(NSUInteger, HEMSettingsTableViewSection) {
    HEMSettingsAccountSection = 0,
    HEMSettingsSupportSection,
    HEMSettingsTellAFriendSection,
    HEMSettingsSectionCount
};

@interface HEMSettingsTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (weak, nonatomic) UILabel *versionLabel;

@end

@implementation HEMSettingsTableViewController

static CGFloat const HEMSettingsSectionHeaderHeight = 12.0f;

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
    [self clearCrumb:HEMBreadcrumbSettings];
    [self updateBadge];
}

- (void)configureTableView {
    CGFloat width = CGRectGetWidth([[self settingsTableView] bounds]);

    // header
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    frame.size.width = width;
    [[self settingsTableView] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
    
    // footer
    [[self settingsTableView] setTableFooterView:[self versionFooterView]];
}

- (UIView*)versionFooterView {
    CGRect footerFrame = CGRectZero;
    footerFrame.size.width = CGRectGetWidth([[self settingsTableView] bounds]);
    
    UIView* footer = [[UIView alloc] initWithFrame:footerFrame];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *vers = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *versionText = [NSString stringWithFormat:@"%@ %@", name, vers];

    UILabel *versionLabel = [[UILabel alloc] init];
    [versionLabel setText:versionText];
    [versionLabel setFont:[UIFont settingsHelpFont]];
    [versionLabel setTextColor:[UIColor textColor]];
    [versionLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [versionLabel sizeToFit];

    CGFloat footerHeight = CGRectGetHeight([footer bounds]);
    CGFloat versionHeight = CGRectGetHeight([versionLabel bounds]);
    CGFloat contentHeight = [[self settingsTableView] contentSize].height + footerHeight;
    CGFloat tableHeight = CGRectGetHeight([[self settingsTableView] bounds]);
    CGFloat versionY = 0.0f;
    if (contentHeight + versionHeight + HEMSettingsBottomMargin < tableHeight) {
        versionY = tableHeight
                    - contentHeight
                    + footerHeight
                    - CGRectGetHeight([versionLabel bounds])
                    - HEMSettingsBottomMargin;
    } else {
        versionY = footerHeight;
    }
    
    CGRect versionFrame = [versionLabel frame];
    versionFrame.origin.x = (CGRectGetWidth([footer bounds]) - CGRectGetWidth(versionFrame)) / 2;
    versionFrame.origin.y = versionY;
    [versionLabel setFrame:versionFrame];

    [footer addSubview:versionLabel];

    // adjust the footer
    footerFrame.size.height = CGRectGetMaxY([versionLabel frame]) + HEMSettingsBottomMargin;
    [footer setFrame:footerFrame];

    [self setVersionLabel:versionLabel];
    
    return footer;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[self settingsTableView] tableFooterView] == nil) {
        [self configureTableView];
    }
    [[self settingsTableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventSettings];
}

- (void)didRefreshAccount {
    [self updateBadge];
}

- (void)updateBadge {
    if (![self isViewLoaded]) {
        BOOL showBadge = [self showIndicatorForCrumb:HEMBreadcrumbSettings];
        self.tabBarItem.badgeValue = showBadge ? @"1" : nil;
        [self reloadTopBar];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HEMSettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HEMSettingsAccountSection:
            return HEMSettingsAccountRowCount;
        case HEMSettingsSupportSection:
            return HEMSettingsSupportRowCount;
        case HEMSettingsTellAFriendSection:
            return HEMSettingsTellAFriendRowCount;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case HEMSettingsSupportSection:
        case HEMSettingsTellAFriendSection:
            return HEMSettingsSectionHeaderHeight;
        case HEMSettingsAccountSection:
        default:
            return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMSettingsTableViewCell *settingsCell = (HEMSettingsTableViewCell *)cell;
    [[settingsCell titleLabel] setText:[self titleForRowAtIndexPath:indexPath]];
    
    if ([indexPath section] == HEMSettingsAccountSection
        && [indexPath row] == HEMSettingsAccountRowIndex) {
        BOOL show = [self showIndicatorForCrumb:HEMBreadcrumbAccount];
        [settingsCell showNewIndicator:show];
    } else {
        [settingsCell showNewIndicator:NO];
    }

    NSInteger numberOfRows = [tableView numberOfRowsInSection:[indexPath section]];

    if ([indexPath row] == 0 && [indexPath row] == numberOfRows - 1) {
        [settingsCell showTopAndBottomCorners];
    } else if ([indexPath row] == 0) {
        [settingsCell showTopCorners];
    } else if ([indexPath row] == numberOfRows - 1) {
        [settingsCell showBottomCorners];
    } else {
        [settingsCell showNoCorners];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch ([indexPath section]) {
        case HEMSettingsAccountSection:
            [self performSegueWithIdentifier:[self segueIdentifierForRow:indexPath.row]
                                      sender:self];
            if ([indexPath row] == HEMSettingsAccountRowIndex) {
                [self clearCrumb:HEMBreadcrumbAccount];
            }
            break;
        case HEMSettingsSupportSection:
            [self performSegueWithIdentifier:[HEMMainStoryboard settingsToSupportSegueIdentifier]
                                      sender:self];
            break;
        case HEMSettingsTellAFriendSection:
            [self tellAFriend];
            break;
        default:
            DDLogDebug(@"Unknown section %ld", (unsigned long) [indexPath section]);
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

- (NSString *)segueIdentifierForRow:(NSUInteger)row {
    switch (row) {
    case HEMSettingsAccountRowIndex:
        return [HEMMainStoryboard accountSettingsSegueIdentifier];
    case HEMSettingsDevicesRowIndex:
        return [HEMMainStoryboard devicesSettingsSegueIdentifier];
    case HEMSettingsUnitsTimeRowIndex:
        return [HEMMainStoryboard unitsSettingsSegueIdentifier];
    case HEMSettingsNotificationRowIndex:
        return [HEMMainStoryboard notificationSettingsSegueIdentifier];

    default:
        return nil;
    }
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSString *title = nil;

    if (section == HEMSettingsAccountSection) {
        switch (row) {
            case HEMSettingsAccountRowIndex:
                title = NSLocalizedString(@"settings.account", nil);
                break;
            case HEMSettingsDevicesRowIndex:
                title = NSLocalizedString(@"settings.devices", nil);
                break;
            case HEMSettingsNotificationRowIndex:
                title = NSLocalizedString(@"settings.notifications", nil);
                break;
            case HEMSettingsUnitsTimeRowIndex:
                title = NSLocalizedString(@"settings.units", nil);
                break;
            default:
                break;
        }
    } else if (section == HEMSettingsSupportSection) {
        switch (row) {
            case HEMSettingsSupportRowIndex:
                title = NSLocalizedString(@"settings.support", nil);
                break;
            default:
                break;
        }
    } else if (section == HEMSettingsTellAFriendSection) {
        switch (row) {
            case HEMSettingsTellAFriendRowIndex:
                title = NSLocalizedString(@"settings.tell-a-friend", nil);
                break;
            default:
                break;
        }
    }

    return title;
}

#pragma mark - Tell a Friend

- (void)tellAFriend {
    [SENAnalytics track:HEMAnalyticsEventTellAFriendTapped];
    
    NSString *subject = NSLocalizedString(@"settings.tell-a-friend.subject", nil);
    NSString *body = NSLocalizedString(@"settings.tell-a-friend.body", nil);
    HEMTellAFriendItemProvider *itemProvider = [[HEMTellAFriendItemProvider alloc] initWithSubject:subject
                                                                                              body:body];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[itemProvider]
                                                                                         applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType,
                                                            BOOL completed,
                                                            NSArray *returnedItems,
                                                            NSError *error) {
        if (error) {
            DDLogError(@"Could not complete share action: %@", error);
        }
        
        if (completed) {
            NSString *type = activityType ?: @"Unknown";
            [SENAnalytics track:HEMAnalyticsEventTellAFriendCompleted
                     properties:@{HEMAnalyticsEventTellAFriendCompletedPropType : type}];
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Cleanup

- (void)dealloc {
    [_settingsTableView setDelegate:nil];
    [_settingsTableView setDataSource:nil];
}

@end
