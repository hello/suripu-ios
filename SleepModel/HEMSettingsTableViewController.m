#import <MessageUI/MessageUI.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "UIFont+HEMStyle.h"

#import "HEMSettingsTableViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertController.h"
#import "HEMLogUtils.h"
#import "HelloStyleKit.h"
#import "HEMSupportUtil.h"

@interface HEMSettingsTableViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView* settingsTableView;
@end

@implementation HEMSettingsTableViewController

static NSInteger const HEMSettingsMyInfoIndex = 0;
static NSInteger const HEMSettingsAccountIndex = 1;
static NSInteger const HEMSettingsUnitsTimeIndex = 2;
static NSInteger const HEMSettingsDevicesIndex = 3;
static NSInteger const HEMSettingsTroubleshootingIndex = 4;
static NSInteger const HEMSettingsSupportIndex = 5;
static NSInteger const HEMSettingsSignOutIndex = 6;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit settingsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self settingsTableView] setTableFooterView:[[UIView alloc] init]];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [[cell textLabel] setText:[self titleForRowAtIndex:indexPath.row]];
    [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
    [[cell textLabel] setFont:[UIFont settingsTitleFont]];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString* nextSegueId = nil;
    switch ([indexPath row]) {
    case HEMSettingsMyInfoIndex:
        nextSegueId = [HEMMainStoryboard infoSettingsSegueIdentifier];
        break;
    case HEMSettingsAccountIndex:
        nextSegueId = [HEMMainStoryboard accountSettingsSegueIdentifier];
        break;
    case HEMSettingsUnitsTimeIndex:
        nextSegueId = [HEMMainStoryboard unitsSettingsSegueIdentifier];
        break;
    case HEMSettingsDevicesIndex:
        nextSegueId = [HEMMainStoryboard devicesSettingsSegueIdentifier];
        break;
    case HEMSettingsTroubleshootingIndex:
        [HEMSupportUtil openHelpFrom:self];
        break;
    case HEMSettingsSupportIndex:
        [HEMSupportUtil contactSupportFrom:[self navigationController] mailDelegate:self];
        break;
    case HEMSettingsSignOutIndex:
        [SENAuthorizationService deauthorize];
        [SENAnalytics track:kHEMAnalyticsEventSignOut];
        break;
    default:
        break;
    }

    if (nextSegueId != nil) {
        [self performSegueWithIdentifier:nextSegueId sender:self];
    }
}

- (NSString*)titleForRowAtIndex:(NSInteger)index {
    switch (index) {
        case HEMSettingsMyInfoIndex:
            return NSLocalizedString(@"settings.info", nil);
        case HEMSettingsAccountIndex:
            return NSLocalizedString(@"settings.account", nil);
        case HEMSettingsUnitsTimeIndex:
            return NSLocalizedString(@"settings.units", nil);
        case HEMSettingsDevicesIndex:
            return NSLocalizedString(@"settings.devices", nil);
        case HEMSettingsTroubleshootingIndex:
            return NSLocalizedString(@"settings.troubleshooting", nil);
        case HEMSettingsSupportIndex:
            return NSLocalizedString(@"settings.contact-support", nil);
        case HEMSettingsSignOutIndex:
            return NSLocalizedString(@"actions.sign-out", nil);
    }
    return nil;
}

#pragma mark - Contact Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
