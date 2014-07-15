
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmSoundTableViewController.h"
#import "HEMColorUtils.h"

static NSString* const SleepCellIdentifier = @"sleepSoundCell";

@interface HEMAlarmSoundTableViewController ()
@property (nonatomic, strong) NSArray* possibleSleepSounds;
@end

@implementation HEMAlarmSoundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewBackground];
    self.possibleSleepSounds = @[ @"None", @"Bells", @"Birdsong", @"Chime", @"Waterfall" ];
}

- (void)configureViewBackground
{
    [self.view.layer insertSublayer:[HEMColorUtils layerWithBlueBackgroundGradientInFrame:self.view.bounds]
                            atIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleSleepSounds.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SleepCellIdentifier forIndexPath:indexPath];

    NSString* sleepSoundText = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    cell.textLabel.text = sleepSoundText;

    if ([sleepSoundText isEqualToString:[SENAlarm savedAlarm].soundName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = [self.possibleSleepSounds indexOfObject:[SENAlarm savedAlarm].soundName];
    if (indexPath.row == index)
        return;

    [SENAlarm savedAlarm].soundName = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    if (index != NSNotFound) {
        NSArray* indexPaths = @[
            [NSIndexPath indexPathForRow:index inSection:0],
            indexPath
        ];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [tableView reloadData];
    }
}

@end
