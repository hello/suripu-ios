#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "HEMSettingsTableViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSettingsTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

@implementation HEMSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self settingsTableView] setTableFooterView:[[UIView alloc] init]];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard settingsCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
            title = NSLocalizedString(@"actions.sign-out", nil);
            break;
        default:
            break;
    }
    [[cell textLabel] setText:title];
    [[cell textLabel] setTextColor:[UIColor whiteColor]];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
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
            [SENAuthorizationService deauthorize];
            break;
        default:
            break;
    }
    
    if (nextSegueId != nil) {
        [self performSegueWithIdentifier:nextSegueId sender:self];
    }
}

@end
