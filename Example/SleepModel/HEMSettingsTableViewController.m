
#import "HEMSettingsTableViewController.h"

@interface HEMSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *clockStyleSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *temperatureSegmentControl;
@end

@implementation HEMSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)temperatureFormatChanged:(UISegmentedControl *)sender {
}

- (IBAction)clockStyleChanged:(UISegmentedControl *)sender {
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
