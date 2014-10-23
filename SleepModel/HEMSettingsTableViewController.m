#import <MessageUI/MessageUI.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "HEMSettingsTableViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMAlertController.h"
#import "HEMLogUtils.h"

@interface HEMSettingsTableViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView* settingsTableView;
@end

@implementation HEMSettingsTableViewController

static NSString* const HEMSettingsContactEmail = @"support@hello.is";
static NSString* const HEMSettingsContactSubject = @"App Support Request";
static NSString* const HEMSettingsLogFileName = @"newest_log_file.log";
static NSString* const HEMSettingsLogFileType = @"text/plain";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self settingsTableView] setTableFooterView:[[UIView alloc] init]];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* title = nil;
    switch ([indexPath row]) {
    case 0:
        title = NSLocalizedString(@"settings.info", nil);
        break;
    case 1:
        title = NSLocalizedString(@"settings.account", nil);
        break;
    case 2:
        title = NSLocalizedString(@"settings.units", nil);
        break;
    case 3:
        title = NSLocalizedString(@"settings.devices", nil);
        break;
    case 4:
        title = NSLocalizedString(@"settings.contact-support", nil);
        break;
    case 5:
        title = NSLocalizedString(@"actions.sign-out", nil);
        break;
    default:
        break;
    }
    [[cell textLabel] setText:title];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString* nextSegueId = nil;
    switch ([indexPath row]) {
    case 0:
        nextSegueId = [HEMMainStoryboard infoSettingsSegueIdentifier];
        break;
    case 1:
        // TODO (jimmy): account settings not implemented yet!
        break;
    case 2:
        nextSegueId = [HEMMainStoryboard unitsSettingsSegueIdentifier];
        break;
    case 3:
        nextSegueId = [HEMMainStoryboard devicesSettingsSegueIdentifier];
        break;
    case 4:
        [self openMailController];
        break;
    case 5:
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

#pragma mark - Contact Support

- (void)openMailController
{
    if (![MFMailComposeViewController canSendMail]) {
        [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"settings.support.fail.title", nil)
                                              message:NSLocalizedString(@"settings.support.fail.message", nil)
                                 presentingController:self];
        return;
    }
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    [controller setToRecipients:@[ HEMSettingsContactEmail ]];
    [controller setSubject:HEMSettingsContactSubject];
    [controller addAttachmentData:[HEMLogUtils latestLogFileData]
                         mimeType:HEMSettingsLogFileType
                         fileName:HEMSettingsLogFileName];
    controller.mailComposeDelegate = self;
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
